output "node_service_account" {
    value = google_service_account.node_service_account.email
}

output "cluster_endpoint" {
    value = google_container_cluster.gke_cluster.endpoint
}

output "cluster_instance_group_urls" {
    value = google_container_cluster.gke_cluster.instance_group_urls
}

output "node_pool_instance_group_urls" {
    value = google_container_node_pool.node_pool.instance_group_urls
}