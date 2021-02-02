variable "environment" {}

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