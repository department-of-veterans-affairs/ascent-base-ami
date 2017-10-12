# Vault issued pki certificates for AWS EC2 instance

## On the vault server
- Create a policy for requesting certs
> vault policy-write ssl_certificates.hcl ssl_certificates.hcl
```
path "pki/issue/vets-api-dot-gov" {
  capabilities = ["create", "read", "update", "list"]
}
```

- Create PKI backend
   See script at https://github.com/department-of-veterans-affairs/ascent-ci-infrastructure/blob/master/vault-config/secret/pki/pki.sh

- Add policy to AWS auth login role, example below
> vault write auth/aws/role/ssh-login auth_type=ec2 bound_account_id=xxxxxxxxxxx policies=default,authorized_keys_read,ssl_certificates ttl=24h

## On the EC2 instances

- Two AWS tags are used to control certificate behavior
  - "Certificate" - if set to "true" the ec2 instance will request a certificate from Vault using its AWS internal hostname as a CN value.
    All other tag values, or the tag not being present result in no certificate request being made
  - "SAN" - comma delimited list of [subject alternative names](https://tools.ietf.org/html/rfc3280#section-4.2.1.7) to be added to the certificate.
    This tag is optional, if present its contents must be either a single DNS name or comma delimited list of several DNS names to be added to the certificate.

- Certificates are requested with a 1 week expiration at system startup and a systemd timer is set to renew 1 week after

- Returned certificates and private key are stored in /home/vaultuser/certs

- Issuing CA cert is copied in pem format to /etc/pki/ca-trust/source/anchors RedHat system location and added to OS via update-ca-trust command
