output "network_id" {
  description = "ID da rede criada"
  value       = hcloud_network.main.id
}

output "subnet_id" {
  description = "ID da sub-rede criada"
  value       = hcloud_subnet.main.id
}

output "network_cidr" {
  description = "CIDR da sub-rede"
  value       = hcloud_subnet.main.ip_range
}
