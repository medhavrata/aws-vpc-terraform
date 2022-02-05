module "rds_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "rds-service"
  description = "Security group for rds with 3306 port open"
  vpc_id      = data.terraform_remote_state.network-config.outputs.vpc_id

  ingress_cidr_blocks = [data.terraform_remote_state.network-config.outputs.vpc_cidr_blocks]
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "RDS"
      cidr_blocks = data.terraform_remote_state.network-config.outputs.vpc_cidr_blocks
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
}