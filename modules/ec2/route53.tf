resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.cloud99.zone_id
  name    = "cloud99.click"
  type    = "A"

  alias {
    name                   = aws_lb.public_alb.dns_name
    zone_id                = aws_lb.public_alb.zone_id
    evaluate_target_health = true
  }
}
