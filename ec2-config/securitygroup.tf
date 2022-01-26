# Define the Security Group
resource "aws_security_group" "private_ec2_01_sg" {
  name        = "allow_ssh"
  description = "Allow SSH traffic with VPC"
  vpc_id      = data.terraform_remote_state.network-config.outputs.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.network-config.outputs.vpc_cidr_blocks]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-terraform"
  description = "Allow HTTP traffic"
  vpc_id      = data.terraform_remote_state.network-config.outputs.vpc_id

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}