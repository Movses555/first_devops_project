# Create aws instance for application 1
resource "aws_instance" "app1_server" {
  ami                    = "ami-03a6eaae9938c858c"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.servers-key.key_name
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ecr_instance_profile.name
  tags = {
    Name = "App1-Server"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo usermod -a -G docker ec2-user
    sudo systemctl start docker
    sudo systemctl enable docker
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 264054630238.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo
  EOF
}

# Create aws instance for application 2
resource "aws_instance" "app2_server" {
  ami                    = "ami-03a6eaae9938c858c"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.servers-key.key_name
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ecr_instance_profile.name
  tags = {
    Name = "App2-Server"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo usermod -a -G docker ec2-user
    sudo systemctl start docker
    sudo systemctl enable docker
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 264054630238.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo
  EOF
}

# Create aws instance for application 3
resource "aws_instance" "app3_server" {
  ami                    = "ami-03a6eaae9938c858c"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.servers-key.key_name
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ecr_instance_profile.name
  tags = {
    Name = "App3-Server"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y docker
    sudo usermod -a -G docker ec2-user
    sudo systemctl start docker
    sudo systemctl enable docker
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 264054630238.dkr.ecr.us-east-1.amazonaws.com/my-ecr-repo
  EOF
}

# Create aws instance for ansible
resource "aws_instance" "ansible_server" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ansible-key.key_name
  vpc_security_group_ids = [aws_security_group.ansible-sg.id]
  tags = {
    Name = "Ansible-Server"
  }

  # Copy ansible installation file to ansible server
  provisioner "file" {
    source      = "./scripts/ansible.sh"
    destination = "/tmp/ansible.sh"
  }

  # Execute ansible.sh file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ansible.sh",
      "sudo /tmp/ansible.sh"
    ]
  }

  # Create directory called test-project
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir test-project",
      "sudo chown -R ubuntu:ubuntu test-project"
    ]
  }

  # Copy application servers keys to ansible server
  provisioner "file" {
    source      = "./keys/servers-key"
    destination = "test-project/servers-key"
  }

  # Change mode of servers key
  provisioner "remote-exec" {
    inline = [
      "chmod 400 test-project/servers-key",
    ]
  }

  # Copy plabook file to ansible server
  provisioner "file" {
    source      = "playbook.yaml"
    destination = "test-project/playbook.yaml"
  }

  # Execute ansible playbook
  provisioner "remote-exec" {
    inline = [
      "export ANSIBLE_HOST_KEY_CHECKING=False",
      "ansible-playbook -e 'server1_ip=${aws_instance.app1_server.private_ip}' -e 'server2_ip=${aws_instance.app2_server.private_ip}' -e 'server3_ip=${aws_instance.app3_server.private_ip}' test-project/playbook.yaml"
    ]
  }

  # Connect to ansible server
  connection {
    user        = "ubuntu"
    private_key = file("./keys/ansible-key")
    host        = self.public_ip
  }
}
