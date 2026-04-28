output "endpoint_id" {
  value = google_vertex_ai_endpoint.saint-gobain-endpoint.id
}

output "psc_ip" {
  value = google_compute_address.psc_ip.address
}

# output "service_attachment" {
#   value = google_vertex_ai_endpoint.saint-gobain-endpoint.private_service_connect_config[0].service_attachment
# }

#curl http://PSC_IP:8080/v1/projects/.../endpoints/...:predict


