provider "hetzner" {
  token = var.hetzner_token
}

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
  network_ids     = [hcloud_network.clienteA_network.id]
}
