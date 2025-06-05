
resource "hcloud_server" "example" {
  name     = "example-server"
  image    = var.server_image
  server_type = var.server_type
  ssh_keys = [var.ssh_key_fingerprint]
}

output "server_ip" {
  value = hcloud_server.example.ipv4_address
}
