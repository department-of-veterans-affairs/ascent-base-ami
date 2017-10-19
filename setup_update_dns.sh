#!/bin/bash -ex

#install bind

sudo cp /tmp/add_server_to_dns.sh /root/

sudo cp /tmp/update-dns.service /usr/lib/systemd/system/update-dns.service

sudo systemctl enable update-dns

