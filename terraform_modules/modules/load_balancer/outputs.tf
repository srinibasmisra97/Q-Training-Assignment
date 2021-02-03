output "url_map_id" {
    value = google_compute_url_map.url_map.map_id
}

output "proxy_id" {
    value = google_compute_target_http_proxy.target_http_proxy.proxy_id
}

output "loadbalancer_ip" {
    value = data.google_compute_global_address.loadbalancer_static_ip.address
}

# output "frontend_label_fingerprints" {
#     value = ["${google_compute_global_forwarding_rule.frontends.*.label_fingerprint}"]

#     depends_on = [ google_compute_target_http_proxy.target_http_proxy ]
# }