FROM jenkins/jenkins:lts

# Switch to root user
USER root

# Install required dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    gnupg \
    software-properties-common \
    lsb-release \
    groovy\
    wget\
    tini

# Manually add HashiCorp GPG key (fixing keyring issue)
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository for Terraform
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Update package list and install Terraform
RUN apt-get update && apt-get install -y terraform

# Clean up unnecessary files
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set tini as the entrypoint
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

# Switch back to Jenkins user
USER jenkins

# Expose Jenkins ports
EXPOSE 8080
EXPOSE 50000
