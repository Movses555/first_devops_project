resource "aws_instance" "app1_server" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.servers-key.key_name
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ecr_instance_profile.name
  tags = {
    Name = "App1-Server"
  }
}

resource "aws_instance" "app2_server" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.servers-key.key_name
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ecr_instance_profile.name
  tags = {
    Name = "App2-Server"
  }
}

resource "aws_instance" "app3_server" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.servers-key.key_name
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ecr_instance_profile.name
  tags = {
    Name = "App3-Server"
  }
}

resource "aws_instance" "ansible_server" {
  ami                    = "ami-053b0d53c279acc90"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ansible-key.key_name
  vpc_security_group_ids = [aws_security_group.ansible-sg.id]
  tags = {
    Name = "Ansible-Server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir test-project",
      "sudo chown -R ubuntu:ubuntu test-project"
    ]
  }

  provisioner "file" {
    source      = "ansible.sh"
    destination = "/tmp/ansible.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/ansible.sh",
      "sudo /tmp/ansible.sh"
    ]
  }

  provisioner "file" {
    source      = "./keys/servers-key"
    destination = "test-project/servers-key"
  }

  provisioner "file" {
    source      = "inventory.yaml"
    destination = "test-project/inventory.yaml"
  }

  provisioner "file" {
    source      = "playbook.yaml"
    destination = "test-project/playbook.yaml"
  }

  provisioner "file" {
    source      = "docker_install.sh"
    destination = "test-project/docker_install.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -i test-project/inventory.yaml test-project/playbook.yml"
    ]
  }

  connection {
    user        = "ubuntu"
    private_key = file("./keys/ansible-key")
    host        = self.public_ip
  }
}

data "aws_instance" "server_1_id" {
  instance_id = aws_instance.app1_server.id
}

data "aws_instance" "server_2_id" {
  instance_id = aws_instance.app2_server.id
}

data "aws_instance" "server_3_id" {
  instance_id = aws_instance.app3_server.id
}


output "server_1_ip" {
  value = data.aws_instance.server_1_id.private_ip
}

output "server_2_ip" {
  value = data.aws_instance.server_2_id.private_ip
}

output "server_3_ip" {
  value = data.aws_instance.server_3_id.private_ip
}