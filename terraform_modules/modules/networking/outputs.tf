output "vpc_network_id" {
    value = google_compute_network.vpc_network.id
    description = "VPC Network ID"
}

output "vpc_network_gateway_ipv4" {
    value = google_compute_network.vpc_network.gateway_ipv4
}

output "subnet_id" {
    value = google_compute_subnetwork.subnet.id
}

output "subnet_gateway_address" {
    value = google_compute_subnetwork.subnet.gateway_address
}