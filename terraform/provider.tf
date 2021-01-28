# Google Provider
provider "google" {
    project = "dev-trials-q"
    credentials = file("/home/srinibas_misra/.gcp-keys/terraform.json")
    region  = "us-central1"
    zone    = "us-central1-a"
}