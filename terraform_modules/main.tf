# VPC Network and Subnet
module "network" {
    source = "./modules/networking"

    vpc_network_name = var.vpc_network_name
    subnet_name = var.subnet_name
    subnet_cidr = var.subnet_cidr
    subnet_region = var.subnet_region
}

# Firewall Rules
module "firewall_rules" {
    source = "./modules/firewall"

    count = length(var.firewall_rules)
    name = var.firewall_rules[count.index].name
    network = var.firewall_rules[count.index].network
    allow_protocol = var.firewall_rules[count.index].allow_protocol
    allow_ports = var.firewall_rules[count.index].allow_ports
    source_ranges = var.firewall_rules[count.index].source_ranges
    target_tags = var.firewall_rules[count.index].target_tags

    depends_on = [ module.network ]
}

module "vm_instance" {
    source = "./modules/vm_instance"
    
    name = var.vm_instance.name
    boot_disk = var.vm_instance.image_name
    machine_type = var.vm_instance.machine_type
    tags = var.vm_instance.network_tags
    subnet = var.vm_instance.subnet
    subnet_region = var.subnet_region

    depends_on = [ module.network ]
}

module "unmanaged_group" {
    source = "./modules/unmanaged_group"

    name = var.unmanaged_group.name
    zone = var.unmanaged_group.zone
    gcp_project = var.gcp_project

    instances = var.unmanaged_group.instances

    named_ports = var.unmanaged_group.named_ports

    depends_on = [ module.vm_instance, module.network, module.firewall_rules ]
}

module "load_balancer" {
    source = "./modules/load_balancer"

    gcp_project = var.gcp_project

    health_checks = var.load_balancer.health_checks
    backends = var.load_balancer.backends
    url_map = var.load_balancer.url_map
    static_ip = var.load_balancer.static_ip
    target_http_proxy = var.load_balancer.target_http_proxy
    frontends = var.load_balancer.frontends

    depends_on = [ module.unmanaged_group ]
}