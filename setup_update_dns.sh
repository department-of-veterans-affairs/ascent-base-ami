#!/bin/bash -ex

#install bind

sudo cp /tmp/dns/add_server_to_dns.sh /root/

sudo cp /tmp/dns/update-dns.service /usr/lib/systemd/system/update-dns.service

sudo systemctl enable update-dns

