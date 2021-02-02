data "google_compute_image" "boot_disk" {
    name = var.boot_disk
}

data "google_compute_subnetwork" "subnet" {
    name = var.subnet
    region = var.subnet_region
}

resource "google_compute_instance" "vm_instance" {
    name = var.name
    machine_type = var.machine_type

    boot_disk {
        initialize_params {
            image = data.google_compute_image.boot_disk.self_link
        }
    }

    tags = var.tags

    network_interface {
        subnetwork = data.google_compute_subnetwork.subnet.self_link

        access_config {

        }
    }
}