terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}


resource "hcloud_server" "main" {
  count             = var.server_count
  name              = "${var.server_type}-${count.index}"
  image             = var.image
  server_type       = var.server_type
  location          = "fsn1"
  # networks          = [var.network_id]
  ssh_keys          = [var.ssh_key_fingerprint]
}

resource "hcloud_floating_ip" "main" {
  count          = var.server_count
  type           = "ipv4"
  home_location  = "fsn1"
}

resource "hcloud_floating_ip_assignment" "main" {
  count           = var.server_count
  server_id       = hcloud_server.main[count.index].id
  floating_ip_id  = hcloud_floating_ip.main[count.index].id
}
