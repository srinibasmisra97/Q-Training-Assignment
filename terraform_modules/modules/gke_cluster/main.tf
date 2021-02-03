# GKE Nodes Service Account
resource "google_service_account" "node_service_account" {
    account_id = var.service_account
    display_name = var.service_account
}

resource "google_project_iam_member" "node_service_account" {
    project = var.gcp_project
    role = "roles/storage.objectViewer"
    member = "serviceAccount:${google_service_account.node_service_account.email}"
    depends_on = [ google_service_account.node_service_account ]
}

# GKE Cluster
resource "google_container_cluster" "gke_cluster" {
    name = var.cluster_name
    location = "us-central1-a"

    remove_default_node_pool = true
    initial_node_count = 1
}

# Node Pool
resource "google_container_node_pool" "node_pool" {
    name = var.node_pool_name
    location = var.node_pool_location

    cluster = google_container_cluster.gke_cluster.name

    node_count = var.node_pool_count

    node_config {
        preemptible = var.node_config.preemptible
        machine_type = var.node_config.machine_type

        service_account = google_service_account.node_service_account.email
        oauth_scopes = [ "https://www.googleapis.com/auth/cloud-platform" ]
    }

    depends_on = [ google_service_account.node_service_account ]
}