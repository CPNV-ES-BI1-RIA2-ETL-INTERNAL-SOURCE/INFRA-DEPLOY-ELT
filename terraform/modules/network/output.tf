output "vpc_id" {
  value       = aws_vpc.main_vpc.id
}

output "dmz_subnet_id" {
  value       = aws_subnet.DMZ.id
}

output "created_private_subnets_infos" {
  value       = [ for idx, subnet in aws_subnet.private_subnet : {
      id = subnet.id
      name = subnet.tags["Name"]
      cidr_block = subnet.cidr_block
  }]
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "dmz_route_table_id" {
  value = aws_route_table.dmz_route_table.id
}

output "private_subnet_route_ids" {
  value = [ for route in aws_route_table.private_subnet_routes : route.id]
}

output "private_subnet_sg_ids" {
  value = [ for sg in aws_security_group.private_subnet_sg : sg.id]
}

output "public_ip" {
  value = aws_eip.elastic_ip.public_ip
}

output "nat_dns_entries" {
  value = [ for record in aws_route53_record.nat_dns_entries : record.name ]
}

output "natsrv_private_ip" {
  value = local.natsrv_private_ip
}