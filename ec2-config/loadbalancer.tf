resource "aws_lb" "public-alb" {
  name               = "public-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in data.terraform_remote_state.network-config.outputs.public_subnets : subnet.id]

  tags = {
    Environment = "development"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.public-alb.arn
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

