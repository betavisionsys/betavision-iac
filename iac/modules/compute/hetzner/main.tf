variable "network_id" {
  type = string
}

variable "image" {
  type = string
}

variable "server_type" {
  type = string
}

variable "count" {
  type = number
}

variable "ssh_key_fingerprint" {
  type = string
}

resource "hcloud_server" "main" {
  count             = var.count
  name              = "\${var.server_type}-\${count.index}"
  image             = var.image
  server_type       = var.server_type
  location          = "fsn1"
  networks          = [var.network_id]
  ssh_keys          = [var.ssh_key_fingerprint]
}

resource "hcloud_floating_ip" "main" {
  count          = var.count
  type           = "ipv4"
  home_location  = "fsn1"
}

resource "hcloud_floating_ip_assignment" "main" {
  count           = var.count
  server_id       = hcloud_server.main[count.index].id
  floating_ip_id  = hcloud_floating_ip.main[count.index].id
}

output "server_ips" {
  value = hcloud_floating_ip.main[*].ip
}
