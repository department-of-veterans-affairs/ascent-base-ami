#!/bin/bash

# setup ssh to get authorized keys from Vault

########################################

set -x

sudo sed -i 's@SELINUX=enforcing@SELINUX=permissive@' /etc/selinux/config
sudo cat /etc/selinux/config
sudo setenforce Permissive

sudo cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
sudo sed -i 's@AuthorizedKeysFile .ssh/authorized_keys@AuthorizedKeysFile none@' /etc/ssh/sshd_config
sudo sed -i 's@#AuthorizedKeysCommand none@AuthorizedKeysCommand /etc/ssh/ssh-command.sh@' /etc/ssh/sshd_config
sudo sed -i 's@#AuthorizedKeysCommandUser nobody@AuthorizedKeysCommandUser vaultuser@' /etc/ssh/sshd_config
sudo sed -i 's@#LogLevel INFO@LogLevel VERBOSE@' /etc/ssh/sshd_config
sudo systemctl restart sshd

cat > /tmp/ssh-command.sh << 'EOF'
#!/bin/bash

#############################################
#
#  Environment Variables Needed:
#
#  VAULT_URL = vault hostname, in our case an AWS ELB
#  VAULT_TOKEN = token for authenticating to vault and reading key file
#
#############################################

#set -x

source /home/vaultuser/.vault/vars

if [ "$1" == "ec2-user" ]
then
        curl -s http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key
        exit 0
else
# Check vault
curl -sk -H "X-Vault-Token:$VAULT_TOKEN" https://$VAULT_URL:8200/v1/secret/authorized_keys/$1 | jq -r '.data|join("\n")'
fi

exit 0
EOF

sudo mv /tmp/ssh-command.sh /etc/ssh
sudo chown root:root /etc/ssh/ssh-command.sh
sudo chmod 755 /etc/ssh/ssh-command.sh

exit 0

