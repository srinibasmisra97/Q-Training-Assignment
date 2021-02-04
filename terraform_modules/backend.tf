# Terraform GCS State Backup
terraform {
    backend "gcs" {
        bucket = "dev-trials-q-terraform-state-backup"
        credentials = "C:\\Users\\Srinibas Mishra\\Documents\\Q-Training-Assignment\\terraform-state-backup.json"
    }
}