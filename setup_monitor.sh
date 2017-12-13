#!/bin/bash -ex

sudo mkdir -p /apps/prometheus/node_exporter/
sudo chown -R ec2-user:ec2-user /apps
cd /apps/prometheus/node_exporter/

## we got node scraper from curl -LO "https://github.com/prometheus/node_exporter/releases/download/0.12.0rc3/node_exporter-0.12.0rc3.linux-amd64.tar.gz"
#mv /tmp/node_exporter-0.12.0rc3.linux-amd64.tar.gz /apps/prometheus/node_exporter/
curl -LO "https://github.com/prometheus/node_exporter/releases/download/0.12.0rc3/node_exporter-0.12.0rc3.linux-amd64.tar.gz"
tar -xvf node_exporter-0.12.0rc3.linux-amd64.tar.gz
rm -rf node_exporter-0.12.0rc3.linux-amd64.tar.gz

sudo cp /tmp/prometheus_node_exporter.service /usr/lib/systemd/system/prometheus_node_exporter.service

sudo systemctl enable prometheus_node_exporter.service
sudo systemctl start prometheus_node_exporter.service
