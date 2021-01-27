# Google Provider
provider "google" {
    project = "dev-trials-q"
    credentials = file("/home/srinibas_misra/.gcp-keys/terraform.json")
    region  = "us-central1"
    zone    = "us-central1-a"
}

resource "google_compute_network" "vpc_network" {
  name = "tf-q-training"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_network_subnet" {
  name          = "tf-us-central1"
  ip_cidr_range = "10.120.0.0/20"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "firewall_allow_app_ports" {
    name = "tf-q-training-5000-5022"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = "tcp"
        ports = ["5000", "5022"]
    }

    source_ranges = ["0.0.0.0/0"]

    target_tags = ["q-training-server"]
}

resource "google_compute_firewall" "firewall_allow_iap" {
    name = "tf-q-training-allow-iap"
    network = google_compute_network.vpc_network.name

    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["35.235.240.0/20"]
}

data "google_compute_image" "q_training_image" {
    project = "dev-trials-q"
    name = "q-training-app"
}

resource "google_compute_instance" "q_training_server" {
    name = "tf-q-training"
    machine_type = "e2-micro"

    boot_disk {
        initialize_params {
            image = data.google_compute_image.q_training_image.self_link
        }
    }

    tags = ["http-server", "https-server", "q-training-server"]

    network_interface {
        network = google_compute_network.vpc_network.self_link
        subnetwork = google_compute_subnetwork.vpc_network_subnet.self_link

        access_config {

        }
    }
}

resource "google_compute_instance_group" "unmanaged_group" {
    name = "tf-training-apps"
    zone = "us-central1-a"
    instances = [google_compute_instance.q_training_server.id]

    named_port {
        name = "http"
        port = "80"
    }

    named_port {
        name = "app1"
        port = "5000"
    }

    named_port {
        name = "app2"
        port = "5022"
    }
}

resource "google_compute_health_check" "app1_tcp_health_check" {
    name = "tf-app1"

    timeout_sec = 5
    check_interval_sec = 10

    tcp_health_check {
        port = "5000"
    }
}

resource "google_compute_health_check" "app2_tcp_health_check" {
    name = "tf-app2"

    timeout_sec = 5
    check_interval_sec = 10

    tcp_health_check {
        port = "5022"
    }
}

resource "google_compute_backend_service" "app1_backend" {
    name = "tf-app1"
    
    health_checks = [google_compute_health_check.app1_tcp_health_check.id]

    port_name = "app1"

    protocol = "HTTP"

    backend {
        group = google_compute_instance_group.unmanaged_group.self_link
    }
}

resource "google_compute_backend_service" "app2_backend" {
    name = "tf-app2"

    health_checks = [google_compute_health_check.app2_tcp_health_check.id]

    port_name = "app2"

    protocol = "HTTP"

    backend {
        group = google_compute_instance_group.unmanaged_group.self_link
    }
}

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

resource "google_compute_target_http_proxy" "target_http_proxy" {
    name = "tf-training-apps-target-http-proxy"
    url_map = google_compute_url_map.urlmap.id
}

data "google_compute_global_address" "loadbalancer_static_ip" {
    name = "tf-training-app"
}

resource "google_compute_global_forwarding_rule" "http_frontend" {
    name = "tf-training-apps-http-forwarding-rule"
    target = google_compute_target_http_proxy.target_http_proxy.id
    port_range = "80"
    ip_address = data.google_compute_global_address.loadbalancer_static_ip.address
}