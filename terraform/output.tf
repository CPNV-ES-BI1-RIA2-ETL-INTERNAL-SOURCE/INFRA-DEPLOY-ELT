output "vpc_id" {
  value       = module.network.vpc_id
}

output "public_ip" {
  value       = module.network.public_ip
}

output "nat_dns_entries" {
  value = module.network.nat_dns_entries
}