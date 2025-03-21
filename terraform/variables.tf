variable "vpc" {
    type        = map(string)
    default     = {
        name = "VPC"
        cidr_block = "10.0.0.0/16"
    }
    description = "VPC base information"
}

variable "dmz_subnet" {
    type        = map(string)
    default     = {
        subnet_name: "DMZ",
        cidr_block: "10.0.0.0/28"
    }
    description = "Public subnet base information"
}

variable "natsrv_private_ip" {
    description = "The private IP address of the NAT server"
    type        = string
    default     = "10.0.0.5"
}

variable "private_subnets" {
    type       = list(object({
        subnet_name = string
        cidr_block  = string
        nbr_host    = number
    }))
    default    = [
        {
            subnet_name = "Private1"
            cidr_block  = "10.10.10.10/28"
            nbr_host    = 1
        }]
    description = "Private subnets base information. List in terraform.tfvars.json"
}

variable "allowed_ips" {
    type        = list(string)
    default     = ["0.0.0.0/0"]
    description = "Allowed IPs for the security group"
}

variable "igw_name" {
    type = string
    default = "IGW"
    description = "IGW name"
}

variable "host_instance_type" {
    type        = string
    default     = "t3.micro"
    description = "Instance type"
}

variable "host_ami" {
    type        = string
    default     = "ami-08613ebea86dc5d60"
    description = "AMI ID"
}

variable "natsrv_instance_type" {
    type        = string
    default     = "t3.micro"
    description = "Instance type"
}

variable "natsrv_ami" {
    type        = string
    default     = "ami-08613ebea86dc5d60"
    description = "AMI ID"
}

variable "route53_tld" {
    type        = string
    default     = "cld.education"
    description = "The top-level domain for the Route 53 hosted zone"
}

locals {
    environment = terraform.workspace
}