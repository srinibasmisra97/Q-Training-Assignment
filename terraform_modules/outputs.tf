output "vpc_network_id" {
    value = module.network.vpc_network_id
    description = "VPC Network ID"
}

output "vpc_network_gateway_ipv4" {
    value = module.network.vpc_network_gateway_ipv4
    description = "VPC Network Gateway IPv4 Address"
}

output "subnet_id" {
    value = module.network.subnet_id
    description = "VPC Subnet ID"
}

output "subnet_gateway_address" {
    value = module.network.subnet_gateway_address
    description = "VPC Subnet Gateway Address"
}

output "vm_internal_ip" {
    value = module.vm_instance.internal_ip
}

output "vm_external_ip" {
    value = module.vm_instance.external_ip
}

output "group_id" {
    value = module.unmanaged_group.group_id
}