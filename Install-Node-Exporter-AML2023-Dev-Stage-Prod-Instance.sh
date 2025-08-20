#!/bin/bash
set -e

# Update system and install dependencies
sudo dnf update -y
sudo dnf install -y wget tar

# Create dedicated user if not already created
if ! id "node_exporter" &>/dev/null; then
  sudo useradd --no-create-home --shell /bin/false node_exporter
fi

# Download and install Node Exporter v1.8.1
NODE_EXPORTER_VERSION="1.8.1"
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo cp node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64

# Create systemd service file
sudo tee /etc/systemd/system/node-exporter.service > /dev/null <<EOL
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl enable --now node-exporter

# Show status
sudo systemctl status node-exporter --no-pager
