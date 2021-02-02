# VPC Network and Subnet
module "network" {
    source = "./modules/networking"

    vpc_network_name = "${var.environment}-${var.vpc_network_name}"
    subnet_name = "${var.environment}-${var.subnet_name}"
    subnet_cidr = var.subnet_cidr
    subnet_region = var.subnet_region
}

# Firewall Rules
module "firewall_rules" {
    source = "./modules/firewall"

    count = length(var.firewall_rules)
    name = "${var.environment}-${var.firewall_rules[count.index].name}"
    network = "${var.environment}-${var.firewall_rules[count.index].network}"
    allow_protocol = var.firewall_rules[count.index].allow_protocol
    allow_ports = var.firewall_rules[count.index].allow_ports
    source_ranges = var.firewall_rules[count.index].source_ranges
    target_tags = var.firewall_rules[count.index].target_tags
}

module "vm_instance" {
    source = "./modules/vm_instance"
    
    name = "${var.environment}-${var.vm_instance.name}"
    boot_disk = var.vm_instance.image_name
    machine_type = var.vm_instance.machine_type
    tags = var.vm_instance.network_tags
    subnet = "${var.environment}-${var.vm_instance.subnet}"
    subnet_region = var.subnet_region
}