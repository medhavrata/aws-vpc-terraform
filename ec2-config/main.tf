###########################################################################################################################
# Creating the Auto Scaling Group
###########################################################################################################################
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "asg-01"

  min_size                  = 2
  max_size                  = 10
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "ELB"
  vpc_zone_identifier       = data.terraform_remote_state.network-config.outputs.private_subnets
  target_group_arns         = module.alb.target_group_arns


  # Launch template
  lc_name                = "example-asg"
  description            = "Launch template example"
  update_default_version = true

  use_lc    = true
  create_lc = true

  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  security_groups             = [module.web_server_sg.security_group_id]
  # security_groups             = [module.testing_sg.security_group_id]
  # key_name = "public_ec2_01_kp"
  iam_instance_profile_name = aws_iam_instance_profile.session_manager_access.name
  # ebs_optimized     = true
  # enable_monitoring = true

  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y

  EOF

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]
}

###########################################################################################################################
# Creating the Application Load Balancer
# ###########################################################################################################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "my-alb"

  load_balancer_type = "application"

  vpc_id          = data.terraform_remote_state.network-config.outputs.vpc_id
  subnets         = data.terraform_remote_state.network-config.outputs.public_subnets
  security_groups = [module.elb_sg.security_group_id]

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      # target_type      = "instance"
      # targets = [
      #   {
      #     target_id = "i-0123456789abcdefg"
      #     port      = 80
      #   },
      #   {
      #     target_id = "i-a1b2c3d4e5f6g7h8i"
      #     port      = 8080
      #   }
      # ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate_validation.cloud99_cert_val.certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}

###########################################################################################################################
# Creating the Route53 Record for the Domain
# ###########################################################################################################################
# module "records" {
#   source  = "terraform-aws-modules/route53/aws//modules/records"
#   version = "~> 2.0"

#   zone_name = data.aws_route53_zone.cloud99.name
#   # zone_id = data.aws_route53_zone.cloud99.zone_id

#   records = [
#     {
#       name = "cloud99.click"
#       type = "A"
#       alias = {
#         name                   = module.alb.lb_dns_name
#         zone_id                = module.alb.lb_zone_id
#       }
#     },
#   ]

#   depends_on = [module.alb]
# }

resource "aws_route53_record" "dns_val" {
  for_each = {
    for dvo in aws_acm_certificate.cloud99_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.cloud99.zone_id
  # name    = "cloud99.click"
  # type    = "A"

  # alias {
  #   name                   = module.alb.lb_dns_name
  #   zone_id                = module.alb.lb_zone_id
  #   evaluate_target_health = true
  # }
}

resource "aws_route53_record" "www" {
  # for_each = {
  #   for dvo in aws_acm_certificate.cloud99_cert.domain_validation_options : dvo.domain_name => {
  #     name   = dvo.resource_record_name
  #     record = dvo.resource_record_value
  #     type   = dvo.resource_record_type
  #   }
  # }

  # allow_overwrite = true
  # name            = each.value.name
  # records         = [each.value.record]
  # ttl             = 60
  # type            = each.value.type
  zone_id = data.aws_route53_zone.cloud99.zone_id
  name    = "cloud99.click"
  type    = "A"

  alias {
    name                   = module.alb.lb_dns_name
    zone_id                = module.alb.lb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cloud99_cert" {
  domain_name       = "cloud99.click"
  validation_method = "DNS"

  tags = {
    Environment = "test"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cloud99_cert_val" {
  certificate_arn         = aws_acm_certificate.cloud99_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_val : record.fqdn]
}