variable "gcp_project" {
    type = string
}

variable "health_checks" {
    type = list(object({
        name = string
        timeout_sec = number
        check_interval_sec = number
        tcp_port = number
    }))
}

variable "backends" {
    type = list(object({
        name = string
        health_check = string
        port_name = string
        protocol = string
        instance_group = string
        zone = string
    }))
}

variable "url_map" {
    type = object({
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
}

variable "static_ip" {
    type = string
}

variable "target_http_proxy" {
    type = string

    default = "target_http_proxy"
}

variable "target_https_proxy" {
    type = object({
        name = string
        certificate = string
    })

    default = null
}

variable "ssl" {
    type = bool

    default = false
}

variable "ssl_certificate" {
    type = object({
        name = string
        domains = list(string)
    })

    default = null
}

variable "frontends" {
    type = list(object({
        name = string
        target = string
        port = string
    }))
}