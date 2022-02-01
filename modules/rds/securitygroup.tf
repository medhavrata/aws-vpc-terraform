resource "aws_security_group" "rds_sg" {
  name        = "allow_3306"
  description = "Allow 3306 traffic with VPC"
  vpc_id      = data.terraform_remote_state.network-config.outputs.vpc_id

  ingress {
    description = "RDS"
    from_port   = 3306
    to_port     = 3306
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
    Name = "allow_rds"
  }
}
