data "aws_route53_zone" "main" {
  zone_id = "Z0326993CH1V95A88MLF"
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "store"
  type    = "A"

  alias {
    name                   = aws_lb.rails_alb.dns_name
    zone_id                = aws_lb.rails_alb.zone_id
    evaluate_target_health = true
  }
}