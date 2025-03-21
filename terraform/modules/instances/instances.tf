resource "aws_instance" "NatSrv" {
    ami           = var.natsrv_ami
    instance_type = var.natsrv_instance_type
    subnet_id     = var.dmz_subnet_id
    private_ip    = var.natsrv_private_ip

    tags = {
        Name = "NatSrv"
    }
    
    key_name = "ria2_sysadm"
    source_dest_check = false
}


resource "aws_instance" "cluster_host" {
    count         = length(local.subnet_hosts)
    ami           = var.host_ami
    instance_type = var.host_instance_type
    subnet_id     = local.subnet_hosts[count.index].subnet_id
    associate_public_ip_address = false

    private_ip    = cidrhost(local.subnet_hosts[count.index].subnet_cidr_block, local.subnet_hosts[count.index].vm_index + 4)

    tags = {
        Name = local.subnet_hosts[count.index].name
    }

    vpc_security_group_ids = [local.subnet_hosts[count.index].instance_sg_id]

    key_name = "ria2_sysadm"

    user_data = templatefile("${path.module}/access.sh", {
      client_key = var.key_pairs[count.index].public_key
    })

    depends_on = [var.key_pairs]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../../../ansible/cluster_hosts.ini"
  content = templatefile("${path.module}/inventory.tpl", {
    nat_instance    = aws_instance.NatSrv
    nat_dns_entries = var.nat_dns_entries
    cluster_hosts   = [for i in range(length(aws_instance.cluster_host)) : aws_instance.cluster_host[i]]
  })

  depends_on = [aws_instance.NatSrv, aws_instance.cluster_host, var.nat_dns_entries]
}

resource "local_file" "ssh_private_key" {
  count    = length(var.key_pairs)
  filename = "${path.module}/../../export/${var.key_pairs[count.index].key_name}/ssh_connection_string.txt"
  content  = templatefile("${path.module}/ssh_connection_string.tpl", {
    ssh_key = var.key_pairs[count.index].key_name
    client_name = var.key_pairs[count.index].key_name
    public_fqdn = var.nat_dns_entries[0]
  })
}