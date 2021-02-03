variable "gcp_project" {}

variable "vpc_network_name" {}
variable "subnet_name" {}
variable "subnet_cidr" {}
variable "subnet_region" {}

variable "firewall_rules" {
    type = list(object({
        name = string
        network = string
        allow_protocol = string
        allow_ports = list(string)
        source_ranges = list(string)
        target_tags = list(string)
    }))
}

variable "vm_instance" {
    type = object({
        name = string
        image_name = string
        machine_type = string
        network_tags = list(string)
        subnet = string
    })
}

variable "unmanaged_group" {
    type = object({
        name = string
        zone = string
        instances = list(string)
        named_ports = list(object({
            name = string
            port = string
        }))
    })
}

variable "load_balancer" {
    type = object({
        health_checks = list(object({
            name = string
            timeout_sec = number
            check_interval_sec = number
            tcp_port = number
        }))

        backends = list(object({
            name = string
            health_check = string
            port_name = string
            protocol = string
            instance_group = string
            zone = string
        }))

        url_map = object({
            name = string
            default_service = string
            host_rules = list(object({
                hosts = list(string)
                path_matcher = string
            }))
            path_matchers = list(object({
                name = string
                service = string
            }))
        })

        static_ip = string
        target_http_proxy = string

        ssl = bool
        ssl_certificate = object({
            name = string
            domains = list(string)
        })
        target_https_proxy = object({
            name = string
            certificate = string
        })

        frontends = list(object({
            name = string
            target = string
            port = string
        }))
    })
}