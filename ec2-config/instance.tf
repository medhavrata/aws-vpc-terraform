# EC2 Instance
resource "aws_instance" "private_ec2_01" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  subnet_id                   = data.terraform_remote_state.network-config.outputs.private_subnets[0].id
  security_groups             = [aws_security_group.private_ec2_01_sg.id]
  key_name                    = "public_ec2_01_kp" # this is manually created, delete this key

  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y

  EOF
  tags = {
    Name = "Private-EC2"
  }
}
