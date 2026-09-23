#!/bin/bash

set -e

echo "Updating system..."
sudo apt update -y

echo "Installing Docker..."
sudo apt install -y docker.io unzip

echo "Starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "Installing AWS CLI..."
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install

echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo ""
echo "======================================"
echo "Installation Completed Successfully!"
echo "======================================"

docker --version
aws --version
kubectl version --client

echo ""
echo "Refreshing docker group..."
newgrp docker <<EOF
echo "Docker group activated."
docker --version
EOF

echo ""
echo "Setup completed successfully."