#!/usr/bin/env bash

mkdir -p /home/admin/.ssh
chmod -R go= /home/admin/.ssh
echo -e "${client_key}" >> /home/admin/.ssh/authorized_keys