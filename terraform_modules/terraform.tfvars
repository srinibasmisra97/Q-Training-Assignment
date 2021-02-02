vpc_network_name = "tf-q-training"
subnet_name = "tf-us-central1"
subnet_cidr = "10.120.0.0/20"
subnet_region = "us-central1"

firewall_rules = [
    {
        network = "tf-q-training"
        name = "tf-q-training-allow-iap"
        allow_protocol = "tcp"
        allow_ports = ["22"]
        source_ranges = ["35.235.240.0/20"]
        target_tags = []
    },
    {
        network = "tf-q-training"
        name = "tf-q-training-5000-5022"
        allow_protocol = "tcp"
        allow_ports = ["5000", "5022"]
        source_ranges = ["0.0.0.0/0"]
        target_tags = ["q-training-server"]
    }
]

vm_instance = {
    name = "tf-q-training"
    image_name = "q-training-app"
    machine_type = "e2-micro"
    network_tags = ["http-server", "https-server", "q-training-server"]
    network = "tf-q-training"
    subnet = "tf-us-central1"
}