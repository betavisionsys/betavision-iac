provider "hcloud" {
  token = "test_token"
}

resource "hcloud_server" "example" {
  name     = "example-server"
  image    = "ubuntu-20.04"
  server_type = "cx11"
  ssh_keys = ["your_ssh_key"]
}

output "server_ip" {
  value = hcloud_server.example.ipv4_address
}
