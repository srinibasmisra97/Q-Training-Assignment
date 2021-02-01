# Terraform GCS State Backup
terraform {
    backend "gcs" {
        bucket = "dev-trials-q-terraform-state-backup"
        credentials = "/home/srinibas_misra/.gcp-keys/terraform-state-backup.json"
    }
}