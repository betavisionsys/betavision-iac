terraform {
  required_providers {
    hcloud = {
      source = "hashicorp/hcloud"
    }
  }
}


resource "hcloud_network" "main" {
  name = var.name
}

resource "hcloud_subnet" "main" {
  network_id    = hcloud_network.main.id
  type          = "cloud"
  network_zone  = var.location
  ip_range      = var.cidr
}
