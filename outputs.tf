output "project_name" {
  value = var.project_name
}

output "aws_region" {
  value = var.aws_region
}
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_1" {
  value = aws_subnet.public_1.id
}

output "public_subnet_2" {
  value = aws_subnet.public_2.id
}

output "private_app_subnet_1" {
  value = aws_subnet.private_app_1.id
}

output "private_app_subnet_2" {
  value = aws_subnet.private_app_2.id
}
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}
output "ecs_instance_role_name" {
  value = aws_iam_role.ecs_instance_role.name
}

output "ecs_instance_profile_name" {
  value = aws_iam_instance_profile.ecs_instance_profile.name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
output "ecr_repository_url" {
  value = aws_ecr_repository.store_app.repository_url
}
output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
output "alb_dns_name" {
  value = aws_lb.rails_alb.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.rails_tg.arn
}
output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}
output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.rails.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.rails.name
}

output "ecs_capacity_provider_name" {
  value = aws_ecs_capacity_provider.main.name
}
output "alb_url" {
  value = aws_lb.rails_alb.dns_name
}

output "route53_url" {
  value = "https://store.${var.domain_name}"
}