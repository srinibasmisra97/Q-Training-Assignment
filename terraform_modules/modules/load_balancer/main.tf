# Health Checks
resource "google_compute_health_check" "health_checks" {
    count = length(var.health_checks)

    name = var.health_checks[count.index].name
    timeout_sec = var.health_checks[count.index].timeout_sec
    check_interval_sec = var.health_checks[count.index].check_interval_sec
    
    tcp_health_check {
        port = var.health_checks[count.index].tcp_port
    }
}

# Instance Group Data Resources
# data "google_compute_instance_group" "unmanaged_group" {
#     count = length(var.backends)
#     name = var.backends[count.index].instance_group
# }

# Backend Services
resource "google_compute_backend_service" "backend_services" {
    count = length(var.backends)

    name = var.backends[count.index].name
    health_checks = ["projects/${var.gcp_project}/global/healthChecks/${var.backends[count.index].health_check}"]
    port_name = var.backends[count.index].port_name
    protocol = var.backends[count.index].protocol
    backend {
        # group = data.google_compute_instance_group.unmanaged_group[count.index].self_link
        group = "projects/${var.gcp_project}/zones/${var.backends[count.index].zone}/instanceGroups/${var.backends[count.index].instance_group}"
    }

    depends_on = [ google_compute_health_check.health_checks ]
}

# Default Backend Service Data Resource
data "google_compute_backend_service" "default_service" {
    name = var.url_map.default_service

    depends_on = [ google_compute_backend_service.backend_services ]
}

# URL Map
resource "google_compute_url_map" "url_map" {
    name = var.url_map.name
    default_service = data.google_compute_backend_service.default_service.id

    dynamic "host_rule" {
        for_each = var.url_map.host_rules
        content {
            hosts = host_rule.value["hosts"]
            path_matcher = host_rule.value["path_matcher"]
        }
    }

    dynamic "path_matcher" {
        for_each = var.url_map.path_matchers
        content {
            name = path_matcher.value["name"]
            default_service = "projects/${var.gcp_project}/global/backendServices/${path_matcher.value.service}"
        }
    }

    depends_on = [ google_compute_backend_service.backend_services ]
}

# Target HTTP Proxy
resource "google_compute_target_http_proxy" "target_http_proxy" {
    name = var.target_http_proxy
    url_map = google_compute_url_map.url_map.id
    depends_on = [ google_compute_url_map.url_map ]
}

# Load Balancer Static IP
data "google_compute_global_address" "loadbalancer_static_ip" {
    name = var.static_ip
}

# HTTP Frontend
resource "google_compute_global_forwarding_rule" "frontends" {
    count = length(var.frontends)

    name = var.frontends[count.index].name
    target = "projects/${var.gcp_project}/global/targetHttpProxies/${var.frontends[count.index].target}"
    port_range = var.frontends[count.index].port
    ip_address = data.google_compute_global_address.loadbalancer_static_ip.address

    depends_on = [ google_compute_target_http_proxy.target_http_proxy ]
}