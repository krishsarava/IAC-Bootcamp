#!/bin/bash
set -e

# Update package list and install dependencies
apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    gnupg \
    software-properties-common \
    lsb-release \
    groovy \
    wget \
    tini \
    net-tools \
    docker.io

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Get the Linux distribution name
DISTRO=$(lsb_release -cs)

# Add HashiCorp repository for Terraform
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${DISTRO} main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update package list again and install Terraform
apt-get update && apt-get install -y terraform

# Install ArgoCD CLI
curl -sSL -o /usr/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/bin/argocd

# Verify ArgoCD installation
export PATH=$PATH:/usr/bin
echo "export PATH=\$PATH:/usr/bin" >> ~/.bashrc
source ~/.bashrc
argocd version || echo "❌ ArgoCD CLI installation failed!"

# Clean up unnecessary files
apt-get clean && rm -rf /var/lib/apt/lists/*

# Start Jenkins
exec /usr/local/bin/jenkins.sh
