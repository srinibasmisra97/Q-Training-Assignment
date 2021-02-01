# VPC Network
resource "google_compute_network" "vpc_network" {
  name = "${var.environment}-${var.vpc_network_subnet_name}"
  auto_create_subnetworks = false
}

# VPC Network Subnet
resource "google_compute_subnetwork" "vpc_network_subnet" {
  name          = "${var.environment}-${var.vpc_network_subnet_name}"
  ip_cidr_range = var.vpc_network_subnet_cidr
  region        = var.vpc_network_subnet_region
  network       = google_compute_network.vpc_network.id
}

# VPC Network Firewall Rules
resource "google_compute_firewall" "firewall_allow_app_ports" {
    name = "${var.environment}-${var.firewall_allow_app_ports.name}"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = var.firewall_allow_app_ports.allow_protocol
        ports = var.firewall_allow_app_ports.allow_ports
    }

    source_ranges = var.firewall_allow_app_ports.source_ranges

    target_tags = var.firewall_allow_app_ports.target_tags
}

resource "google_compute_firewall" "firewall_allow_iap" {
    name = "${var.environment}-${var.firewall_allow_iap.name}"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = var.firewall_allow_iap.allow_protocol
        ports = var.firewall_allow_iap.allow_ports
    }

    source_ranges = var.firewall_allow_iap.source_ranges
}

# Data OS Image
data "google_compute_image" "q_training_image" {
    project = var.gcp_project
    name = var.vm_instance.image_name
}

# GCE VM Instance
resource "google_compute_instance" "q_training_server" {
    name = "${var.environment}-${var.vm_instance.name}"
    machine_type = var.vm_instance.machine_type

    boot_disk {
        initialize_params {
            image = data.google_compute_image.q_training_image.self_link
        }
    }

    tags = var.vm_instance.network_tags

    network_interface {
        network = google_compute_network.vpc_network.self_link
        subnetwork = google_compute_subnetwork.vpc_network_subnet.self_link

        access_config {

        }
    }
}

# GCE Unmanaged Instance Group
resource "google_compute_instance_group" "unmanaged_group" {
    name = "${var.environment}-${var.vm_unmanaged_instance_group.name}"
    zone = var.gcp_zone
    instances = [google_compute_instance.q_training_server.id]

    dynamic "named_port" {
        for_each = var.vm_unmanaged_instance_group.named_ports

        content {
            name = named_port.value["name"]
            port = named_port.value["port"]
        }
    }
}

# GCP HTTP(s) Load Balancer
# GCP Compute Health Check
resource "google_compute_health_check" "app1_tcp_health_check" {
    name = "${var.environment}-${var.lb_health_check_app1.name}"

    timeout_sec = var.lb_health_check_app1.timeout_sec
    check_interval_sec = var.lb_health_check_app1.check_interval_sec

    tcp_health_check {
        port = var.lb_health_check_app1.port
    }
}

resource "google_compute_health_check" "app2_tcp_health_check" {
    name = "${var.environment}-${var.lb_health_check_app2.name}"

    timeout_sec = var.lb_health_check_app2.timeout_sec
    check_interval_sec = var.lb_health_check_app2.check_interval_sec

    tcp_health_check {
        port = var.lb_health_check_app2.port
    }
}

# GCP Backend Service
resource "google_compute_backend_service" "app1_backend" {
    name = "${var.environment}-${var.lb_backend_app1.name}"
    
    health_checks = [google_compute_health_check.app1_tcp_health_check.id]

    port_name = var.lb_backend_app1.port_name

    protocol = var.lb_backend_app1.protocol

    backend {
        group = google_compute_instance_group.unmanaged_group.self_link
    }
}

resource "google_compute_backend_service" "app2_backend" {
    name = "${var.environment}-${var.lb_backend_app2.name}"

    health_checks = [google_compute_health_check.app2_tcp_health_check.id]

    port_name = var.lb_backend_app2.port_name

    protocol = var.lb_backend_app2.protocol

    backend {
        group = google_compute_instance_group.unmanaged_group.self_link
    }
}

# GCP URL Map
resource "google_compute_url_map" "urlmap" {
    name = "tf-training-app"

    default_service = google_compute_backend_service.app1_backend.id

    host_rule {
        hosts = ["app1.q-training-tf.tk"]
        path_matcher = "app1-path-matcher"
    }

    host_rule {
        hosts = ["app2.q-training-tf.tk"]
        path_matcher = "app2-path-matcher"
    }

    path_matcher {
        name = "app1-path-matcher"
        default_service = google_compute_backend_service.app1_backend.id
    }

    path_matcher {
        name = "app2-path-matcher"
        default_service = google_compute_backend_service.app2_backend.id
    }
}

# GCP Target HTTP Proxy
resource "google_compute_target_http_proxy" "target_http_proxy" {
    name = "tf-training-apps-target-http-proxy"
    url_map = google_compute_url_map.urlmap.id
}

# GCP Managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "ssl_certificate" {
    name = "tf-training-app-cert"

    managed {
        domains = ["app1.q-training-tf.tk", "app2.q-training-tf.tk"]
    }
}

# GCP Target HTTPS Proxy
resource "google_compute_target_https_proxy" "target_https_proxy" {
    name = "tf-training-apps-target-https-proxy"
    url_map = google_compute_url_map.urlmap.id
    ssl_certificates = [google_compute_managed_ssl_certificate.ssl_certificate.id]
}

# Global Static IP
data "google_compute_global_address" "loadbalancer_static_ip" {
    name = "tf-training-app"
}

# GCP Global Forwarding Rule
resource "google_compute_global_forwarding_rule" "http_frontend" {
    name = "tf-training-apps-http-forwarding-rule"
    target = google_compute_target_http_proxy.target_http_proxy.id
    port_range = "80"
    ip_address = data.google_compute_global_address.loadbalancer_static_ip.address
}

resource "google_compute_global_forwarding_rule" "https_frontend" {
    name = "tf-training-apps-https-forwarding-rule"
    target = google_compute_target_https_proxy.target_https_proxy.id
    port_range = "443"
    ip_address = data.google_compute_global_address.loadbalancer_static_ip.address
}