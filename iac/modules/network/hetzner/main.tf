variable "name" {
  type = string
}

variable "cidr" {
  type = string
}

variable "location" {
  type = string
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

output "network_id" {
  value = hcloud_network.main.id
}

output "subnet_id" {
  value = hcloud_subnet.main.id
}

output "network_cidr" {
  value = hcloud_subnet.main.ip_range
}
