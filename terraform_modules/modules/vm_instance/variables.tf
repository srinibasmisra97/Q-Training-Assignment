variable "name" {
    type = string
    description = "Name of VM Instance"
}

variable "machine_type" {
    type = string
    description = "Machine type"

    default = "e2-micro"
}

variable "boot_disk" {
    type = string
    description = "Disk OS Image"
}

variable "tags" {
    type = list(string)
    description = "List of network tags"

    default = []
}

variable "subnet" {
    type = string
    description = "Subnet of the VPC, the instance is attached to"
}

variable "subnet_region" {
    type = string
    description = "Region of the subnet. Should be same as VM region"
}