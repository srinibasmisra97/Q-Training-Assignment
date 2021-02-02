# VPC Network
resource "google_compute_network" "vpc_network" {
    name = var.vpc_network_name
    auto_create_subnetworks = false
}

# Subnets
resource "google_compute_subnetwork" "subnet" {
    name = var.subnet_name
    ip_cidr_range = var.subnet_cidr
    region = var.subnet_region
    network = google_compute_network.vpc_network.id
}