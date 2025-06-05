terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}


resource "hcloud_network" "main" {
  name     = var.name
  ip_range = var.cidr
}
