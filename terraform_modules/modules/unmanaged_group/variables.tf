variable "name" {
    type = string
}

variable "zone" {
    type = string
}

variable "gcp_project" {
    type = string
}

variable "instances" {
    type = list(string)
}

variable "named_ports" {
    type = list(object({
        name = string
        port = string
    }))
}