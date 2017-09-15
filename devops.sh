#!/bin/bash -ex

sudo useradd -m devops
sudo passwd -d devops
sudo echo "devops        ALL=(ALL)       NOPASSWD: ALL" | sudo tee -a /etc/sudoers

exit 0
