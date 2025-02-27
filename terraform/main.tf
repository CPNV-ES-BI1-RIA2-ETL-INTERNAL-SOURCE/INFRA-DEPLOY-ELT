module "network" {
  source = "./modules/network"

  dmz_subnet = var.dmz_subnet
  private_subnets = var.private_subnets
  vpc = var.vpc
  igw_name = var.igw_name
  allowed_ips = var.allowed_ips
  natsrv_private_ip = var.natsrv_private_ip
  NatSrv_primary_network_interface_id = module.instances.NatSrv_primary_network_interface_id
}

module "instances" {
  source = "./modules/instances"
  private_subnets = var.private_subnets
  natsrv_private_ip = var.natsrv_private_ip
  vpc_id = module.network.vpc_id
  dmz_subnet_id = module.network.dmz_subnet_id
  created_private_subnets_infos = module.network.created_private_subnets_infos
  private_subnet_sg_ids = module.network.private_subnet_sg_ids
  natsrv_instance_type = var.natsrv_instance_type
  natsrv_ami = var.natsrv_ami
  host_instance_type = var.host_instance_type
  host_ami = var.host_ami
}