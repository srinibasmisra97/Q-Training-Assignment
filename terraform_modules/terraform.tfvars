gcp_project = "dev-trials-q"

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

unmanaged_group = {
    name = "tf-training-apps"
    zone = "us-central1-a"
    instances = ["tf-q-training"]
    named_ports = [
        {name = "http", port = "80"},
        {name = "app1", port = "5000"},
        {name = "app2", port = "5022"}
    ]
}

load_balancer = {
    health_checks = [
        {name = "tf-app1", timeout_sec = 5, check_interval_sec = 10, tcp_port = 5000},
        {name = "tf-app2", timeout_sec = 5, check_interval_sec = 10, tcp_port = 5022}
    ]

    backends = [
        {name = "tf-app1", health_check = "tf-app1", port_name = "app1", protocol = "HTTP", instance_group = "tf-training-apps", zone = "us-central1-a"},
        {name = "tf-app2", health_check = "tf-app2", port_name = "app2", protocol = "HTTP", instance_group = "tf-training-apps", zone = "us-central1-a"}
    ]

    url_map = {
        name = "tf-q-training"
        default_service = "tf-app1"
        host_rules = [
            {hosts = ["app1.q-training-tf-modules.tk"], path_matcher = "app1-path-matcher"},
            {hosts = ["app2.q-training-tf-modules.tk"], path_matcher = "app2-path-matcher"}
        ]
        path_matchers = [
            {name = "app1-path-matcher", service = "tf-app1"},
            {name = "app2-path-matcher", service = "tf-app2"}
        ]
    }

    static_ip = "tf-training-app"
    target_http_proxy = "tf-training-apps-target-http-proxy"

    ssl = true
    target_https_proxy = {
        name = "tf-training-apps-target-https-proxy",
        certificate = "tf-training-certificate"
    }
    ssl_certificate = {
        name = "tf-training-certificate",
        domains = ["app1.q-training-tf-modules.tk", "app2.q-training-tf-modules.tk"]
    }

    frontends = [
        {name = "tf-training-http-frontend", target = "tf-training-apps-target-http-proxy", port = "80"},
        {name = "tf-training-https-frontend", target = "tf-training-apps-target-https-proxy", port = "443"}
    ]
}

gke_cluster = {
    service_account = "tf-gke-nodes"
    cluster_name = "tf-q-training"
    node_pool_name = "training-app-pool"
    node_pool_location = "us-central1-a"
    node_pool_count = 1
    node_config = {
        preemptible = true
        machine_type = "e2-micro"
    }
}