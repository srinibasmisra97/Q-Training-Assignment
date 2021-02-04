# Google Provider
provider "google" {
    project = "dev-trials-q"
    credentials = file("C:\\Users\\Srinibas Mishra\\Documents\\Q-Training-Assignment\\terraform.json")
    region  = "us-central1"
    zone    = "us-central1-a"
}