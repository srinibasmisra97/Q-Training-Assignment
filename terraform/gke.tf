# GKE Nodes Service Account
resource "google_service_account" "gke_node_default" {
    account_id = "tf-gke-nodes"
    display_name = "TF GKE Nodes"
}

resource "google_project_iam_member" "storage_object_viewer" {
    project = "dev-trials-q"
    role    = "roles/storage.objectViewer"
    member  = "serviceAccount:tf-gke-nodes@dev-trials-q.iam.gserviceaccount.com"
}

# GKE Cluster
resource "google_container_cluster" "gke_cluster" {
    name = "tf-q-training"
    location = "us-central1-a"

    remove_default_node_pool = true
    initial_node_count = 1
}

# GKE Cluster Node Pool
resource "google_container_node_pool" "gke_app_node_pool" {
    name = "training-app-pool"
    location = "us-central1-a"

    cluster = google_container_cluster.gke_cluster.name
    
    node_count = 1

    node_config {
        preemptible = true
        machine_type = "e2-medium"

        service_account = google_service_account.gke_node_default.email
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}