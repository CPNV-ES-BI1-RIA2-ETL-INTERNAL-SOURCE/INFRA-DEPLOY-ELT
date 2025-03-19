output "key_pairs" {
  value = [
    for i in range(length(var.sshkey_list)) : {
      key_name    = aws_key_pair.clients_sshkey[i].key_name
      public_key  = tls_private_key.ssh_key_pairs[i].public_key_openssh
      private_key = tls_private_key.ssh_key_pairs[i].private_key_openssh
    }
  ]
  sensitive = true
  description = "List of SSH key details including key name, public key, and private key"
}

output "key_pairs_id" {
  value = aws_key_pair.clients_sshkey[*].id
}