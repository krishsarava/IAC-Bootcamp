provider "aws" {
  region = "us-east-2"
}

# Moved variable "private_key" to a separate variables.tf file
variable "key"   { default = ""}

resource "aws_instance" "jkconsole" {
  count    = 1
  key_name = "15-key-sarava"

  tags = {
    Name  = "15-tf-jknode"
    owner = "Saravanan Krishnan"
  }

  launch_template {
    id      = "lt-05c810971e0111ae7"
    version = "1"
  }

  # Securely pass the private key from Jenkins credentials
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.key)  # Ensures proper key reading
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for instance to stabilize...'",
       "sudo apt-get update",
       "sudo apt-get install -y git docker.io docker-compose ansible maven unzip curl gnupg software-properties-common",
      "sleep 5",
      "echo 'Ensuring unzip is installed...'",
      "sudo apt-get install -y unzip",
      "sleep 5",
      "echo 'Downloading Terraform binary...'",
      "curl -fsSL -o terraform.zip https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip",
      "unzip terraform.zip",
      "sudo mv terraform /usr/local/bin/",
      "sudo chmod +x /usr/local/bin/terraform",
      "rm terraform.zip",
      "echo 'Verifying Terraform installation...'",
      "terraform version || echo 'Terraform installation failed!'",
      "sudo systemctl enable --now docker",
      "sudo snap  install kubectl --classic",
      "sudo apt install -y openjdk-11-jdk",
      "sudo usermod -aG docker ubuntu",
      "echo 'Installation Complete!'"
   
    ]
    
  }
 
}
# Output the public IP of the instance
output "instance_ip" {
  description = "The public IP of the created EC2 instance"
  value       = aws_instance.jkconsole[0].private_ip
}
