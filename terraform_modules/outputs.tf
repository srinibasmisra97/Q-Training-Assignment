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

output "url_map_id" {
    value = module.load_balancer.url_map_id
}

output "proxy_id" {
    value = module.load_balancer.proxy_id
}

output "loadbalancer_ip" {
    value = module.load_balancer.loadbalancer_ip
}

output "node_service_account" {
    value = module.gke_cluster.node_service_account
}

output "cluster_endpoint" {
    value = module.gke_cluster.cluster_endpoint
}

output "cluster_instance_group_urls" {
    value = module.gke_cluster.cluster_instance_group_urls
}

output "node_pool_instance_group_urls" {
    value = module.gke_cluster.node_pool_instance_group_urls
}