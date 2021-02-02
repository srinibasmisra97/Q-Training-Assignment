data "google_compute_instance" "vm_instances" {
    count = length(var.instances)
    name = var.instances[count.index]
}

resource "google_compute_instance_group" "unmanaged_instance_group" {
    name = var.name
    zone = var.zone

    # instances = formatlist("projects/${var.gcp_project}/zone/${var.zone}/instances/%s", var.instances)
    instances = data.google_compute_instance.vm_instances[*].self_link
    dynamic "named_port" {
        for_each = var.named_ports

        content {
            name = named_port.value["name"]
            port = named_port.value["port"]
        }
    }
}