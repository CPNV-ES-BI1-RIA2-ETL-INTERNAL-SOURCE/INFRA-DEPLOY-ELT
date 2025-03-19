resource "tls_private_key" "ssh_key_pairs" {
    count = length(var.sshkey_list)
    algorithm = "ED25519"
}

resource "aws_key_pair" "clients_sshkey" {
    count = length(var.sshkey_list)
    key_name   = var.sshkey_list[count.index]
    public_key = tls_private_key.ssh_key_pairs[count.index].public_key_openssh
}