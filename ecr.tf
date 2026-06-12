resource "aws_ecr_repository" "store_app" {
  name                 = "store-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "store-app"
  }
}

resource "aws_ecr_lifecycle_policy" "store_app_policy" {
  repository = aws_ecr_repository.store_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}