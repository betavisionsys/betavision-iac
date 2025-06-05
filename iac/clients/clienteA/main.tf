terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.40"
    }
  }
}

provider "hcloud" {}

resource "hcloud_network" "clienteA_network" {
  name     = var.network_name
  ip_range = var.network_cidr
}

resource "hcloud_server" "clienteA_server" {
  count           = var.server_count
  name            = "clienteA-server-${count.index}"
  image           = var.server_image
  server_type     = var.server_type
  location        = var.location
  ssh_keys        = [var.ssh_key_fingerprint]
  network {
    network_id = hcloud_network.clienteA_network.id
  }
}
