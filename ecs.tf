resource "aws_ecs_cluster" "main" {
  name = "rails-store-cluster"
}
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}
resource "aws_launch_template" "ecs" {

  name_prefix = "rails-store-ecs-"
  image_id    = data.aws_ssm_parameter.ecs_ami.value

  instance_type = "t3.small"

  key_name = var.key_pair_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.ecs_sg.id
  ]

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
  )
}
resource "aws_autoscaling_group" "ecs" {

  name = "rails-store-ecs-asg"

  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = [
    aws_subnet.private_app_1.id,
    aws_subnet.private_app_2.id
  ]

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "rails-store-ecs"
    propagate_at_launch = true
  }
}
resource "aws_ecs_capacity_provider" "main" {

  name = "rails-store-capacity-provider"

  auto_scaling_group_provider {

    auto_scaling_group_arn = aws_autoscaling_group.ecs.arn

    managed_scaling {
      status = "ENABLED"

      target_capacity = 100
    }
  }
}
resource "aws_ecs_cluster_capacity_providers" "main" {

  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.main.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
  }
}
resource "aws_ecs_task_definition" "rails" {
  family                   = "rails-store"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "rails-app"
      image = "${aws_ecr_repository.store_app.repository_url}:latest"

      cpu    = 256
      memory = 512

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 0
        }
      ]

      environment = [
        {
          name  = "RAILS_ENV"
          value = "production"
        },
        {
          name  = "RAILS_MASTER_KEY"
          value = "82bd6aa4873741005e93300e00406fbb"
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER_NAME"
          value = var.db_username
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/rails-store"
          awslogs-region        = "ap-south-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
resource "aws_ecs_service" "rails" {
  name            = "rails-store-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.rails.arn
  desired_count   = 1
  launch_type     = "EC2"

  # Health check grace period
  health_check_grace_period_seconds = 180

  # Deployment configuration
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  load_balancer {
    target_group_arn = aws_lb_target_group.rails_tg.arn
    container_name   = "rails-app"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.http
  ]
}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/rails-store"
  retention_in_days = 7
}