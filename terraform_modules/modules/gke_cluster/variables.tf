variable "gcp_project" {
    type = string
}

variable "service_account" {
    type = string
    default = "gke-nodes-sa"
}

variable "cluster_name" {
    type = string
}

variable "node_pool_name" {
    type = string
}

variable "node_pool_location" {
    type = string
}

variable "node_pool_count" {
    type = number
}

variable "node_config" {
    type = object({
        preemptible = bool
        machine_type = string
    })
}