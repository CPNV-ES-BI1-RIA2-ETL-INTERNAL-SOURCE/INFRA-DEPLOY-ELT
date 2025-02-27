[nat_servers]
${nat_instance.tags.Name} ansible_host=${nat_instance.public_ip}

[cluster_hosts]
%{ for host in cluster_hosts ~}
${host.tags.Name} ansible_host=${host.private_ip} ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -q -W %h:%p admin@${nat_instance.public_ip}"'
%{ endfor ~}