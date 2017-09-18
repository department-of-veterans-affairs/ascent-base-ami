# Vault aws auth setup

## On the vault server
- Create a policy (ex. authorized_keys_read.hcl) file for reading the secret, and write it to vault 
	> vault policy-write authorized_keys_read authorized_keys_read.hcl
	```
	path "secret/authorized_keys/*" {
   	capabilities = ["read"]
	}
	```

- Create authorized_keys secret backend and populate with the list of ssh public (PIV) keys 
  (tested with 50 keys, unsure of data limit per secret)
	> vault write secret/authorized_keys/\<username\> \
	> user_name=.ssh-rsa AAAA.... \
	> user_name2=.ssh-rsa AAAA.... \

- Enable AWS Auth backend
	> vault auth-enable aws

- Add access and secret key for Vault to use to communicate with AWS API
	> vault write auth/aws/config/client secret_key=\<secret key\> access_key=\<access key data\>

- Create a role for AWS ec2 login.  This example restricts authorization to ec2 instance owned by our account, and issues tokens that last for 24 hours.  Token ttl will need to match the time period set in the aws auth script on the ec2 instance.
	> ./vault write auth/aws/role/ssh-login auth_type=ec2 bound_account_id=<our aws account id> policies=default,authorized_keys_read ttl=24h

## On the EC2 instances

- EC2 instance will need an instance profile that allows it to describe ELB resources in order to discover the Vault ELB.

- A vaultuser account is created, this account manages the vault token and nonce, and runs the SSH Authorized Users command. The aws_auth.sh script that performs the aws auth is run at system boot and every 24 hours following; this allows a new token to be obtained as the existing token expires.  

- SSH daemon configuration is changed to disallow AuthorizedKeysFile and use an AuthorizedKeysCommand script that checks presented key agains the Vault authorized_keys endpoint for the specified OS user.  There is fallback access via the ec2-user and the key that was specified during instance creation.


## Login process

- See https://csra-evss.atlassian.net/browse/DOP-643 for instructions on using PuTTY-CAC with PIV card for login.
