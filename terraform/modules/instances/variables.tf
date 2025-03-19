variable "natsrv_instance_type" {
    type        = string
    description = "Instance type"
}

variable "natsrv_ami" {
    type        = string
    description = "AMI ID"
}

variable natsrv_private_ip {
    description = "The private IP address of the NAT server"
    type        = string
}

variable "host_instance_type" {
    type        = string
    description = "Instance type"
}

variable "host_ami" {
    type        = string
    description = "AMI ID"
}

variable "vpc_id" {
    description = "The CIDR block for the VPC"
    type        = string
}

variable "dmz_subnet_id" {
    description = "The CIDR block for the DMZ subnet"
    type        = string
}

variable "environment" {
    type        = string
    description = "Environment"
}

variable "created_private_subnets_infos" {
  description = "List of private subnet IDs and naaaames"
  type = list(object({
    id   = string
    name = string
    cidr_block = string
  }))
}

variable "private_subnet_sg_ids" {
  description = "List of private subnet security group IDs"
  type = list(string)
}

variable "private_subnets" {
    type       = list(object({
        subnet_name = string
        cidr_block  = string
        nbr_host    = number
    }))
    description = "Private subnets base information. List in terraform.tfvars.json"
}

variable "nat_dns_entries" { 
    description = "List of NAT DNS entries"
    type = list(string)
}

variable "key_pairs_id" {
    type = list(string)
}

locals {
    subnet_hosts = flatten([
        for subnet_index, subnet in var.created_private_subnets_infos : [
            for instance in range(var.private_subnets[subnet_index]["nbr_host"]) : {
                subnet_id = subnet.id
                subnet_name= subnet.name
                vm_index = instance + 1
                subnet_cidr_block = subnet.cidr_block
                name = "${subnet.name}-host-${format("%02d", instance + 1)}"
                instance_sg_id = var.private_subnet_sg_ids[subnet_index]
            }
        ]   
    ])
}