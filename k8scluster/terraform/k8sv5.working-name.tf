provider "aws" {
  region  = "us-east-2"
  }

  # Moved variable "private_key" to a separate variables.tf file
variable "key"   { default = ""}

resource "aws_instance" "k8smaster" {
  count    = 1
  key_name = "15-key-sarava"

  tags = {
    Name  = "15-tf-K8S-master"
    owner = "Saravanan Krishnan"
    Event = "H1"
  }
  
  launch_template {
    id      = "lt-05c810971e0111ae7"
    version = "1"
  }
}
resource "aws_instance" "k8sworker" {
  count    = 2
  key_name = "15-key-sarava"

  tags = {
    Name  = "15-tf-K8S-wrk${count.index + 1}"
    owner = "Saravanan Krishnan"
    Event = "H1"
  }

  launch_template {
    id      = "lt-05c810971e0111ae7"
    version = "1"
  }

# Move connection inside remote-exec and fix inline script
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key)  # Reads SSH key securely
      host        = self.public_ip
    }

    #  Use only ONE execution method: inline
    inline = [
      "echo 'Connected successfully to $(hostname)'"
    ]
  }
}


#Ensure instances are ready by waiting for SSH to be available
resource "null_resource" "wait_for_instances" {
  depends_on = [aws_instance.k8smaster]

  provisioner "local-exec" {
    command = <<EOT
      for ip in ${join(" ", aws_instance.k8smaster[*].public_ip)}; do
        echo "Waiting for SSH on $ip..."
        until ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.key} ubuntu@$ip "echo SSH ready"; do
          sleep 5
        done
      done
      echo "All instances are ready!"
    EOT
  }
}
#Generate Ansible inventory file with internal IPs
resource "null_resource" "generate_inventory" {
  depends_on = [null_resource.wait_for_instances]

  provisioner "local-exec" {
    command = <<EOT
    rm -f inventory.ini
      echo "[mgr]" > inventory.ini
      echo "master ansible_host=${aws_instance.k8smaster[0].private_ip}" >> inventory.ini
      echo "\n[wrk]" >> inventory.ini
      echo "wrk1 ansible_host=${aws_instance.k8sworker[0].private_ip}" >> inventory.ini
      echo "wrk2 ansible_host=${aws_instance.k8sworker[1].private_ip}" >> inventory.ini
    EOT
  }
}


