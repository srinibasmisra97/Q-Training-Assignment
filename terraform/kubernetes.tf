# Retrieve an access token as the Terraform runner
data "google_client_config" "provider" {}

data "google_container_cluster" "gke_cluster" {
  name     = "tf-q-training"
  location = "us-central1-a"
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.gke_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.gke_cluster.master_auth[0].cluster_ca_certificate,
  )
}

# Kubernetes Namespace
resource "kubernetes_namespace" "q_training_namespace" {
  metadata {
    name = "tf-q-training"
  }
}

# Kubernetes Deployments
# Python App
resource "kubernetes_deployment" "python_app" {
    metadata {
        labels = {
            app = "training-python"
        }

        name = "training-python"
        namespace = "tf-q-training"
    }

    spec {
        replicas = "1"

        selector {
            match_labels = {
                app = "training-python"
            }
        }

        strategy {
            rolling_update {
                max_surge = "25%"
                max_unavailable = "25%"
            }

            type = "RollingUpdate"
        }

        template {
            metadata {
                labels = {
                    app = "training-python"
                }
                
                name = "training-python"
            }

            spec {
                container {
                    name = "python-app"
                    image = "us.gcr.io/dev-trials-q/training-python-app:v0.0"

                    port {
                        container_port = "5000"
                    }

                    liveness_probe {
                        http_get {
                            port = "5000"
                            path = "/"
                        }
                        initial_delay_seconds = 3
                        period_seconds = 5
                    }

                    readiness_probe {
                        http_get {
                            port = "5000"
                            path = "/"
                        }
                        initial_delay_seconds = 3
                        period_seconds = 5
                    }
                }
            }
        }
    }
}

# Node App
resource "kubernetes_deployment" "node_app" {
    metadata {
        labels = {
            app = "training-node"
        }

        name = "training-node"
        namespace = "tf-q-training"
    }

    spec {
        replicas = "1"
        selector {
            match_labels = {
                app = "training-node"
            }
        }

        strategy {
            rolling_update {
                max_surge = "25%"
                max_unavailable = "25%"
            }
            type = "RollingUpdate"
        }

        template {
            metadata {
                labels = {
                    app = "training-node"
                }
                name = "training-node"
            }

            spec {
                container {
                    name = "node-app"
                    image = "us.gcr.io/dev-trials-q/training-node-app:v0.0"
                    
                    port {
                        container_port = "5022"
                    }

                    liveness_probe {
                        http_get {
                            port = "5022"
                            path = "/"
                        }
                        initial_delay_seconds = 3
                        period_seconds = 5
                    }

                    readiness_probe {
                        http_get {
                            port = "5022"
                            path = "/"
                        }
                        initial_delay_seconds = 3
                        period_seconds = 5
                    }
                }
            }
        }
    }
}

# Kubernetes Service
# Python App
resource "kubernetes_service" "python_app" {
    metadata {
        name = "training-python"
    }

    spec {
        selector = {
            app = "training-python"
        }

        port {
            port = "80"
            target_port = "5000"
        }

        type = "LoadBalancer"
    }
}

# Node App
resource "kubernetes_service" "node_app" {
    metadata {
        name = "training-node"
    }

    spec {
        selector = {
            app = "training-node"
        }

        port {
            port = "80"
            target_port = "5022"
        }

        type = "LoadBalancer"
    }
}