resource "aws_vpc" "main_vpc" {
  cidr_block = local.vpc["cidr_block"]

  tags = {
    Name = local.vpc["name"]
  }
}

# DMZ creation
resource "aws_subnet" "DMZ" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.dmz_subnet["cidr_block"]

  tags = {
    Name = var.dmz_subnet["subnet_name"]
  }

  depends_on = [aws_vpc.main_vpc]
}

# Private subnets creation
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnets[count.index]["cidr_block"]

  tags = {
    Name = var.private_subnets[count.index]["subnet_name"]
  }

  depends_on = [aws_vpc.main_vpc]
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  depends_on = [aws_vpc.main_vpc]

  tags = {
    Name = var.igw_name
  }
}

# Routes for DMZ subnet
resource "aws_route_table" "dmz_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "RT-${var.dmz_subnet["subnet_name"]}"
  }
}

# Routes for private subnets
resource "aws_route_table" "private_subnet_routes" {
  count = length(var.private_subnets)
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = local.vpc["cidr_block"]
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = var.NatSrv_primary_network_interface_id
  }

  depends_on = [var.NatSrv_primary_network_interface_id]

  tags = {
    Name = "RT-${var.private_subnets[count.index]["subnet_name"]}"
  }
}

# Elastic IP for the NAT server
resource "aws_eip" "elastic_ip" {
  network_interface = var.NatSrv_primary_network_interface_id
  domain   = "vpc"

  tags = {
    Name = "NAT-IP"
  }

  depends_on = [var.NatSrv_primary_network_interface_id, aws_internet_gateway.igw]
}

# DMZ security group
resource "aws_security_group" "dmz_subnet_sg" {
  name        = "${var.dmz_subnet["subnet_name"]}-sg"
  description = "Security group for public subnet"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.dmz_subnet["subnet_name"]}-sg"
  }
}

# Private subnets security group
resource "aws_security_group" "private_subnet_sg" {
  count = length(var.private_subnets)
  name        = "${var.private_subnets[count.index]["subnet_name"]}-sg"
  description = "Security group for private subnet"
  vpc_id      = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.private_subnets[count.index]["subnet_name"]}-sg"
  }
}

# Security group rules
resource "aws_vpc_security_group_ingress_rule" "dmz_ingress_rules_ssh" {
  count = length(var.allowed_ips)
  security_group_id = aws_security_group.dmz_subnet_sg.id
  cidr_ipv4         = var.allowed_ips[count.index]
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "SSH access from allowed IPs"
}

resource "aws_vpc_security_group_ingress_rule" "dmz_ingress_rules_http" {
  security_group_id = aws_security_group.dmz_subnet_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "HTTP access from everywhere"
}

resource "aws_vpc_security_group_ingress_rule" "dmz_ingress_rules_https" {
  security_group_id = aws_security_group.dmz_subnet_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "HTTPs access from everywhere"
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_from_private_subnets" {
  count = length(var.private_subnets)
  security_group_id = aws_security_group.dmz_subnet_sg.id
  cidr_ipv4         = var.private_subnets[count.index]["cidr_block"]
  ip_protocol       = "-1"
  description       = "Access from ${var.private_subnets[count.index]["subnet_name"]} subnet"
}

resource "aws_vpc_security_group_ingress_rule" "private_subnets_ingress_rules_ssh" {
  count = length(var.private_subnets)
  security_group_id = aws_security_group.private_subnet_sg[count.index].id
  cidr_ipv4         = "${local.natsrv_private_ip}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "SSH access from the nat server"
}

resource "aws_vpc_security_group_ingress_rule" "private_subnets_ingress_rules_http" {
  count = length(var.private_subnets)
  security_group_id = aws_security_group.private_subnet_sg[count.index].id
  cidr_ipv4         = "${local.natsrv_private_ip}/32"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  description       = "HTTP access from the nat server (reverse proxy)"
}

resource "aws_vpc_security_group_ingress_rule" "private_subnets_ingress_rules_https" {
  count = length(var.private_subnets)
  security_group_id = aws_security_group.private_subnet_sg[count.index].id
  cidr_ipv4         = "${local.natsrv_private_ip}/32"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
  description       = "HTTPS access from the nat server (reverse proxy)"
}

resource "aws_vpc_security_group_egress_rule" "dmz_egress_rules" {
  security_group_id = aws_security_group.dmz_subnet_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

resource "aws_vpc_security_group_egress_rule" "private_subnets_egress_rules" {
  count = length(var.private_subnets)
  security_group_id = aws_security_group.private_subnet_sg[count.index].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}

# Routes tables associations
resource "aws_route_table_association" "dmz_subnet_association" {
  subnet_id      = aws_subnet.DMZ.id
  route_table_id = aws_route_table.dmz_route_table.id

  depends_on = [aws_subnet.DMZ, aws_route_table.dmz_route_table]
}

resource "aws_route_table_association" "private_subnet_associations" {
  count = length(var.private_subnets)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_subnet_routes[count.index].id

  depends_on = [aws_subnet.private_subnet, aws_route_table.private_subnet_routes]
}

# Network interface security group attachment (NAT server)
resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.dmz_subnet_sg.id
  network_interface_id = var.NatSrv_primary_network_interface_id

  depends_on = [aws_security_group.dmz_subnet_sg, var.NatSrv_primary_network_interface_id]
}

# DNS records
resource "aws_route53_record" "nat_dns_entries" {
  count = length(local.dns_entries)
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.dns_entries[count.index]["dns_entry"]
  type    = "A"
  ttl     = "300"
  records = [aws_eip.elastic_ip.public_ip]

  depends_on = [aws_eip.elastic_ip]
}

resource "local_file" "dns_entries" {
  filename = "${path.module}/../../../ansible/dns_entries.yml"
  content = yamlencode({
    dns_entries   = local.dns_entries
  })

  depends_on = [aws_route53_record.nat_dns_entries] 
}