output "server_ips" {
  description = "Lista de IPs públicos atribuídos às instâncias"
  value       = hcloud_floating_ip.main[*].ip
}
