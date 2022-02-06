# Define the Security Group
module "web_server_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/http-80"

  name        = "web-server"
  description = "Security group for web-server with HTTP ports open within VPC"
  vpc_id      = data.terraform_remote_state.network-config.outputs.vpc_id

  ingress_cidr_blocks = [data.terraform_remote_state.network-config.outputs.vpc_cidr_blocks]
}


module "elb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "elb-service"
  description = "Security group for elastic lb with HTTP port publicly open"
  vpc_id      = data.terraform_remote_state.network-config.outputs.vpc_id

  ingress_cidr_blocks = [data.terraform_remote_state.network-config.outputs.vpc_cidr_blocks]
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS"
      cidr_blocks = "0.0.0.0/0"
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
