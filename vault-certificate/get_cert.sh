#!/bin/bash

#set -x
BASE_DIR=/home/vaultuser

# If valid cert exists, exit (server rebooted)
openssl x509 -in ${BASE_DIR}/certs/certificate.pem -noout -checkend 0 && exit 0

source /home/vaultuser/.vault/vars
mkdir -p $BASE_DIR/certs

INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`

CERTIFICATE=`aws --output text --region $AWS_REGION ec2 describe-tags --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=tag:Certificate,Values=*" | awk '{print $5}'`

# Source vars again to give vault auth extra time
source /home/vaultuser/.vault/vars

[[ "${CERTIFICATE,,}" == "true" ]] || { echo "Vault certificate not requested"; exit 0;}

SANS=`aws --output text --region $AWS_REGION ec2 describe-tags --filters "Name=resource-id,Values=${INSTANCE_ID}" "Name=tag:SAN,Values=*" | awk {'print $5'}`

CA_EXPIRY=`date --date "$(curl -ks https://$VAULT_URL:8200/v1/pki/ca | openssl x509 -inform der -noout -enddate | sed -n 's/notAfter=//p')" +%s`
let "TTL=($CA_EXPIRY-`date +%s`) / 3600"

curl -ks -H "X-Vault-Token:$VAULT_TOKEN" -X POST https://$VAULT_URL:8200/v1/pki/issue/vets-api-dot-gov -d '{"common_name":"'$HOSTNAME'","alt_names":"'$SANS'","ttl":"'$TTL'h"}' > ${BASE_DIR}/certs/certificate.json

# Save PEM files
jq -r '.data.certificate' ${BASE_DIR}/certs/certificate.json > ${BASE_DIR}/certs/certificate.pem
jq -r '.data.private_key' ${BASE_DIR}/certs/certificate.json > ${BASE_DIR}/certs/private_key.pem
jq -r '.data.issuing_ca' ${BASE_DIR}/certs/certificate.json > ${BASE_DIR}/certs/vets-issuing_ca.pem
chmod 640 ${BASE_DIR}/certs/private_key.pem ${BASE_DIR}/certs/certificate.json

exit 0
