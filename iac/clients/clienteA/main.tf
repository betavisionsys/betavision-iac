provider "hcloud" {
  token = var.hetzner_token
  alias = "hetzner"
}

module "network" {
  source = "../../modules/network/hetzner"
  providers = {
    hcloud = hcloud.hetzner
  }
  name     = var.network_name
  cidr     = var.network_cidr
  location = var.location
}

module "compute" {
  source = "../../modules/compute/hetzner"
  providers = {
    hcloud = hcloud.hetzner
  }
  network_id          = module.network.network_id
  image               = var.server_image
  server_type         = var.server_type
  count               = var.server_count
  ssh_key_fingerprint = var.ssh_key_fingerprint
}
