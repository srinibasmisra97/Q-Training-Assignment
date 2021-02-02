variable "name" {
    type = string
    description = "Name of Firewall Rule"
}

variable "network" {
    type = string
    description = "Name of the network the firewall rule is attached to"
}

variable "allow_protocol" {
    type = string
    description = "Protocol to allow"

    default = "tcp"
}

variable "allow_ports" {
    type = list(string)
    description = "List of ports to allow"

    default = ["80"]
}

variable "source_ranges" {
    type = list(string)
    description = "Source CIDR Ranges to allow"

    default = ["0.0.0.0/0"]
}

variable "target_tags" {
    type = list(string)
    description = "Target tags for the firewall rule"

    default = []
}