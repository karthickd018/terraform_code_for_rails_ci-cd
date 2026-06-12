resource "aws_lb" "rails_alb" {
  name               = "rails-store-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

resource "aws_lb_target_group" "rails_tg" {
  name        = "rails-store-tg-nginx"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"

  vpc_id = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.rails_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.rails_alb.arn

  port     = 443
  protocol = "HTTPS"

  certificate_arn = aws_acm_certificate_validation.app_cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rails_tg.arn
  }
}