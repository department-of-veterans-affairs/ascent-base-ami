#!/bin/bash -ex

set -x
if [ -e /root/nsupdate.txt ]
then
  echo "server already in DNS nothing to do"
else
  #grab intanceID and aws region
  INSTANCE_ID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
  AWS_REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region'`

  echo $INSTANCE_ID

  #pull private dns name to use in update
  PRIVATEDNSNAME=`aws ec2 describe-instances --instance-id $INSTANCE_ID --region $AWS_REGION | jq .Reservations[].Instances[].PrivateDnsName |sed 's/\"//g'`

  #pull the SAN names for an instance
  AWSSANS=`aws ec2 describe-instances  --instance-ids $INSTANCE_ID --region $AWS_REGION | jq '.Reservations[] | .Instances[] | [(.Tags|from_entries|.SAN)]' |sed 's/\"//g' | sed 's/\]//g' | sed 's/\[//g'`

  MASTER_INSTANCE_ID=`aws --output text --region $AWS_REGION ec2 describe-tags --filters 'Name=tag:Type,Values=dns_master' | awk '{print $3}'`
  MASTER_SERVER_IP=`aws ec2 describe-instances --instance-id $MASTER_INSTANCE_ID --region $AWS_REGION | jq .Reservations[].Instances[].PublicIpAddress |sed 's/\"//g'`
  SLAVE_INSTANCE_ID=`aws --output text --region $AWS_REGION ec2 describe-tags --filters 'Name=tag:Type,Values=dns_slave' | awk '{print $3}'`
  SLAVE_SERVER_IP=`aws ec2 describe-instances --instance-id $SLAVE_INSTANCE_ID --region $AWS_REGION | jq .Reservations[].Instances[].PublicIpAddress |sed 's/\"//g'`
  echo $AWSSAN
  echo $PRIVATEDNSNAME

  SANLIST=$(echo $AWSSANS | tr "," "\n")
  echo $SANLIST

  if [ $SANLIST = null ]
  then
    echo "No SAN Tag found. script will exit and not add this server to DNS"
    exit
  else
    echo "zone internal.vets-api.gov." >/root/nsupdate.txt
    echo "server "$MASTER_SERVER_IP >>/root/nsupdate.txt
    for SAN in $SANLIST
    do
       echo "update add" $SAN". 0 CNAME "$PRIVATEDNSNAME >>/root/nsupdate.txt
    done

    echo "send" >>/root/nsupdate.txt

    nsupdate /root/nsupdate.txt
  fi
  #update dhcp address and restart network
  sudo echo "supersede domain-name-servers "$MASTER_SERVER_IP", "$SLAVE_SERVER_IP";" >> /etc/dhcp/dhclient.conf
  sudo /etc/init.d/network restart
fi

