# ascent-base-ami

These scripts build a base image using Hashicorp packer.  SSH access is setup via authorized keys loaded into Hashicorp Vault 
and helper scripts, for more details see the vault_aws_auth directory. 

A default user named "devops" is added with full sudo access.  


## To run
Create user variable JSON file:
```
   {
    "aws_access_key": "xxxxxxxxxxxxxxxxxxxxxxxxx",
    "aws_secret_key": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "aws_region": "us-east-1",
    "base_ami_id": "ami-c998b6b2",
   }
```
and run `packer build -var-file=<your_user_file>.json base.json`
