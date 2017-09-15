#!/bin/bash

set -x

source /home/vaultuser/.vault/vars

# First auth, save nonce returned from Vault
[ -z "$NONCE" ] && curl -ks -X POST https://$VAULT_URL:8200/v1/auth/aws/login -d '{"role":"ssh-login","pkcs7":"'$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n')'"}' | jq -r '.auth.metadata.nonce' > /home/vaultuser/.vault/nonce
NONCE=`cat /home/vaultuser/.vault/nonce 2>/dev/null`
export NONCE

#Save token
curl -ks -X POST https://$VAULT_URL:8200/v1/auth/aws/login -d '{"role":"ssh-login","pkcs7":"'$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n')'","nonce":"'$NONCE'"}' | jq -r '.auth.client_token' > /home/vaultuser/.vault/token


exit 0
