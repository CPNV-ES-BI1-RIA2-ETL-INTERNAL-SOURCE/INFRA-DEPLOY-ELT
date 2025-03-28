variable "dmz_subnet" {
    description = "The CIDR block for the DMZ subnet"
    type        = map
}

variable "private_subnets" {
    type       = list(object({
        subnet_name = string
        cidr_block  = string
        nbr_host    = number
    }))
    description = "Private subnets base information. List in terraform.tfvars.json"
}

variable "environment" {
    type        = string
    description = "Environment"
}

variable "igw_name" {
    type = string
    description = "IGW name"
}

variable "vpc" {
    type        = map(string)
    description = "VPC base information"
}

variable "allowed_ips" {
    type        = list(string)
    description = "Allowed IPs for the security group"
}

variable "NatSrv_primary_network_interface_id" {
    type = string
    description = "The ID of the primary network interface of the NAT server"
}

variable "route53_tld" {
    type = string
    description = "The top-level domain for the Route 53 hosted zone"
}

locals {
    dns_entries = flatten([
        for subnet in var.private_subnets : {
            subnet_name = subnet.subnet_name
            dns_entry = lower("${subnet.subnet_name}.${var.environment}.${var.route53_tld}")
            redirect_ip = cidrhost(subnet["cidr_block"], 5)
        }
    ])
}

locals {
    vpc = {
        name = "${var.vpc["name"]}-${var.environment}"
        cidr_block = var.vpc["cidr_block"]
    }
}

locals {
    natsrv_private_ip = cidrhost(var.dmz_subnet["cidr_block"], -2)
}