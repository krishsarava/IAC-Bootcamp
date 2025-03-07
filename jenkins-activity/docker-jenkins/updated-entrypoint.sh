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
    tini

# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Get the Linux distribution name
DISTRO=$(lsb_release -cs)

# Add HashiCorp repository for Terraform
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${DISTRO} main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update package list again and install Terraform
apt-get update && apt-get install -y terraform

# Install ArgoCD CLI (specific version v2.7.4) with retry mechanism
ARGOCD_VERSION="v2.7.4"
ARGOCD_CLI_URL="https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
ARGOCD_BIN="/usr/local/bin/argocd"

for i in {1..3}; do
    curl -sSL -o argocd-linux-amd64 "$ARGOCD_CLI_URL" && break || sleep 5
done
mv argocd-linux-amd64 "$ARGOCD_BIN"
chmod +x "$ARGOCD_BIN"

# Verify ArgoCD installation
if ! command -v argocd &> /dev/null; then
    echo "❌ ArgoCD CLI installation failed!"
    exit 1
fi

# Clean up unnecessary files
apt-get clean && rm -rf /var/lib/apt/lists/*

# Start Jenkins
exec /usr/local/bin/jenkins.sh
