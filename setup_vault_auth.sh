#!/bin/bash -ex

sudo useradd -r -m vaultuser
sudo mkdir /home/vaultuser/.vault
sudo mv /tmp/aws_auth.sh /home/vaultuser
sudo mv /tmp/vars /home/vaultuser/.vault
sudo chmod 750 /home/vaultuser/aws_auth.sh
sudo chown -R vaultuser:vaultuser /home/vaultuser


sudo chown root:root /tmp/vault-aws-auth*
sudo mv /tmp/vault-aws-auth* /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable vault-aws-auth.service


exit 0
