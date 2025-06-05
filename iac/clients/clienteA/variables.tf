variable "network_name" {
  type    = string
  default = "clienteA-network"
}

variable "network_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "location" {
  type    = string
  default = "fsn1"
}

variable "server_type" {
  type    = string
  default = "cx22"
}

variable "server_image" {
  type    = string
  default = "ubuntu-22.04"
}

variable "server_count" {
  type    = number
  default = 2
}

variable "ssh_key_fingerprint" {
  type = string
}
