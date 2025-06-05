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

# resource "hcloud_subnet" "main" {
#   network_id    = hcloud_network.main.id
#   type          = "cloud"
#   network_zone  = var.location
#   ip_range      = var.cidr
# }
