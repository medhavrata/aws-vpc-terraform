# Deploy EC2 Instances via Auto Scaling Group
resource "aws_launch_configuration" "ec2_launch" {
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = false
  security_groups             = [aws_security_group.private_ec2_01_sg.id]

  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y

  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_01" {
  launch_configuration = aws_launch_configuration.ec2_launch.name
  vpc_zone_identifier  = [for subnet in data.terraform_remote_state.network-config.outputs.private_subnets : subnet.id]

  target_group_arns = [aws_lb_target_group.asg_tg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "terraform-asg"
    propagate_at_launch = true
  }
}
