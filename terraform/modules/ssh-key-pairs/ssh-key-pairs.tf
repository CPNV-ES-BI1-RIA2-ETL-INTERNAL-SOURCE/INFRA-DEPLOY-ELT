resource "tls_private_key" "ssh_key_pairs" {
    count = length(var.sshkey_list)
    algorithm = "ED25519"
}

resource "aws_key_pair" "clients_sshkey" {
    count = length(var.sshkey_list)
    key_name   = var.sshkey_list[count.index]
    public_key = tls_private_key.ssh_key_pairs[count.index].public_key_openssh
}

resource "local_file" "ssh_private_key" {
  count    = length(var.sshkey_list)
  filename = "${path.module}/../../export/${var.sshkey_list[count.index]}/${var.sshkey_list[count.index]}"
  content  = tls_private_key.ssh_key_pairs[count.index].private_key_openssh
}

resource "local_file" "clients" {
  filename = "${path.module}/../../../ansible/vars/clients.yml"
  content = yamlencode({
    clients   = [
      for idx, client_name in var.sshkey_list : {
        name = client_name
        ssh_key = tls_private_key.ssh_key_pairs[idx].public_key_openssh
      }
    ]
  })
}