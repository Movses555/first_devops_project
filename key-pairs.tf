
# Applications servers key-pairs
resource "aws_key_pair" "servers-key" {
  key_name   = "servers-key"
  public_key = file("./keys/servers-key.pub")
}

# Ansible server key-pair
resource "aws_key_pair" "ansible-key" {
  key_name   = "ansible-key"
  public_key = file("./keys/ansible-key.pub")
}