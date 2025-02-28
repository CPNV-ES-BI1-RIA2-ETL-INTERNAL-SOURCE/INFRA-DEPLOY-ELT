variable "dmz_subnet" {
    description = "The CIDR block for the DMZ subnet"
    type        = map
}

variable natsrv_private_ip {
    description = "The private IP address of the NAT server"
    type        = string
}

variable "private_subnets" {
    type       = list(object({
        subnet_name = string
        cidr_block  = string
        nbr_host    = number
    }))
    description = "Private subnets base information. List in terraform.tfvars.json"
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
            dns_entry = lower("${subnet.subnet_name}.${var.route53_tld}")
            redirect_ip = cidrhost(subnet["cidr_block"], 5)
        }
    ])
}