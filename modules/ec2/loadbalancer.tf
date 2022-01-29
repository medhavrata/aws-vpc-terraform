# Deploy the Application Load Balancer
resource "aws_lb" "public_alb" {
  name               = "public-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in data.terraform_remote_state.network-config.outputs.public_subnets : subnet.id]

  tags = {
    Environment = "development"
  }
}

# Define the load balancer listner and give load balancer as an input
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# This is the target group which load balancer will use to send the input requests and 
# Auto Scaling Group will use this target group to launch the instances
resource "aws_lb_target_group" "asg_tg" {
  name     = "terraform-asg-target-grp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network-config.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Load Balancer Listner rule to send the input requests to target group
resource "aws_lb_listener_rule" "asg_lr" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_tg.arn
  }
}
