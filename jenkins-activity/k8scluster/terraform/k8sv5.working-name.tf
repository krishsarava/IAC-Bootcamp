provider "aws" {
  region  = "us-east-2"
  }
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
}
# Securely pass the private key from Jenkins credentials
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.key)  # Ensures proper key reading
    host        = self.public_ip
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
      echo "[mgr]" > inventory.ini
      echo "mgr ansible_host=${aws_instance.k8smaster[0].private_ip}" >> inventory.ini
      echo "\n[wrk]" >> inventory.ini
      echo "wrk1 ansible_host=${aws_instance.k8sworker[0].private_ip}" >> inventory.ini
      echo "wrk2 ansible_host=${aws_instance.k8sworker[1].private_ip}" >> inventory.ini
    EOT
  }
}

# Ansible execution after inventory is generated
resource "null_resource" "ansible_provision" {
  depends_on = [null_resource.generate_inventory]

  provisioner "local-exec" {

    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.ini -u ubuntu --private-key ${var.key} sk-ansible-final.yaml > k8sinstall.log"
  }
}
# Transfer ~/.kube/config to localhost  
 resource "null_resource" "helmconfig" {
  depends_on = [null_resource.ansible_provision]
    provisioner "local-exec" {

    command = "ansible-playbook -i inventory.ini -u ubuntu --private-key ${var.key} kubeconfig-transfer.yaml > kubeconfig.log"
  }
 }
#Deploy Python-redis to k8s cluster
resource "null_resource" "k8sscaling" {
  depends_on = [null_resource.helmconfig]
  provisioner "local-exec" {

    command = "ansible-playbook helmconfig-ansible.yaml > helm.log"
  }
}

#Scaleup pods
resource "null_resource" "done" {
  depends_on = [null_resource.k8sscaling]
  provisioner "local-exec" {

    command = "ansible-playbook scaleup-pods.yaml > scale.log"
  }
}
