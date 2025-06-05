variable "network_id" {
  description = "ID da rede onde serão criadas as instâncias"
  type        = string
}

variable "image" {
  description = "Imagem do sistema (ex: ubuntu-22.04)"
  type        = string
}

variable "server_type" {
  description = "Tipo de servidor (ex: cx31)"
  type        = string
}

variable "server_count" {
  description = "Quantidade de servidores"
  type        = number
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint da chave SSH cadastrada no Hetzner"
  type        = string
}
