# Infrastructure Environment
variable "environment" {}
variable "gcp_project" {}
variable "terraform_credentials" {}
variable "gcp_region" {}
variable "gcp_zone" {}
variable "terraform_state_buckt" {}
variable "terraform_state_credentials" {}

# VPC Network
variable "vpc_network_name" {}

# VPC Network Subnet
variable "vpc_network_subnet_name" {}
variable "vpc_network_subnet_cidr" {}
variable "vpc_network_subnet_region" {}

# Google Compute Firewall
variable "firewall_allow_app_ports" {
    type = object({
        name = string
        allow_protocol = string
        allow_ports = list(string)
        source_ranges = list(string)
        target_tags = list(string)
    })
}

variable "firewall_allow_iap" {
    type = object({
        name = string
        allow_protocol = string
        allow_ports = list(string)
        source_ranges = list(string)
    })
}

# GCE VM Instance
variable "vm_instance" {
    type = object({
        name = string
        image_name = string
        machine_type = string
        network_tags = list(string)
    })
}

# GCE Unmanaged Instance Group
variable "vm_unmanaged_instance_group" {
    type = object({
        name = string

        named_ports = list(object({
            name = string
            port = string
        }))
    })
}

# HTTP(s) Load Balancer
# GCP Compute Health Checks
variable "lb_health_check_app1" {
    type = object({
        name = string

        timeout_sec = number
        check_interval_sec = number

        port = string
    })
}

variable "lb_health_check_app2" {
    type = object({
        name = string

        timeout_sec = number
        check_interval_sec = number

        port = string
    })
}

# Google Compute Backend Services
variable "lb_backend_app1" {
    type = object({
        name = string
        protocol = string
        port_name = string
        instance_group = string
    })
}

variable "lb_backend_app2" {
    type = object({
        name = string
        protocol = string
        port_name = string
        instance_group = string
    })
}