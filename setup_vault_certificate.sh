#!/bin/bash -ex

sudo mv /tmp/get_cert.sh /home/vaultuser
sudo chmod 750 /home/vaultuser/get_cert.sh
sudo chown -R vaultuser:vaultuser /home/vaultuser

sudo chown root:root /tmp/vault-certificate*
sudo mv /tmp/vault-certificate* /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable vault-certificate.service
sudo systemctl enable vault-certificate.timer


exit 0
