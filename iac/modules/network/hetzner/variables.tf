variable "name" {
  description = "Nome da rede"
  type        = string
}

variable "cidr" {
  description = "Faixa de IPs CIDR"
  type        = string
}

variable "location" {
  description = "Datacenter (ex: fsn1)"
  type        = string
}
