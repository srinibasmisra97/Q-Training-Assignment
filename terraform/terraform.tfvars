gcp_project = "dev-trials-q"
terraform_credentials = "/home/srinibas_misra/.gcp-keys/terraform.json"
gcp_region = "us-central1"
gcp_zone = "us-central1-a"
terraform_state_bucket = "dev-trials-q-terraform-state-backup"
terraform_state_credentials = "/home/srinibas_misra/.gcp-keys/terraform-state-backup.json"

vpc_network_name = "tf-q-training"

vpc_network_subnet_name = "tf-us-central1"
vpc_network_subnet_cidr = "10.120.0.0/20"
vpc_network_subnet_region = "us-central1"

firewall_allow_app_ports = {
    name = "tf-q-training-5000-5022"
    allow_protocol = "tcp"
    allow_ports = ["5000", "5022"]
    source_ranges = ["0.0.0.0/0"]
    target_tags = ["q-training-server"]
}

firewall_allow_iap = {
    name = "tf-q-training-allow-iap"
    allow_protocol = "tcp"
    allow_ports = ["22"]
    source_ranges = ["35.235.240.0/20"]
}

vm_instance_image_name = "q-training-app"
vm_instance_name = "tf-q-training"

vm_instance = {
    name = "tf-q-training"
    image_name = "q-training-app"
    machine_type = "e2-micro"
    network_tags = ["http-server", "https-server", "q-training-server"]
}

vm_unmanaged_instance_group = {
    name = "tf-training-apps"

    named_ports = [
        {name="http", port="80"},
        {name="app1", port="5000"},
        {name="app2", port="5022"}
    ]
}

lb_health_check_app1 = {
    name = "tf-app1"
    timeout_sec = 5
    check_interval_sec = 10
    port = "5000"
}

lb_health_check_app2 = {
    name = "tf-app2"
    timeout_sec = 5
    check_interval_sec = 10
    port = "5022"
}

lb_backend_app1 = {
    name = "tf-app1"
    port_name = "app1"
    protocol = "HTTP"
    instance_group = "tf-training-apps"
}

lb_backend_app2 = {
    name = "tf-app2"
    port_name = "app2"
    protocol = "HTTP"
    instance_group = "tf-training-apps"
}