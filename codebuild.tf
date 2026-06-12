data "aws_caller_identity" "current" {}
resource "aws_codebuild_project" "rails_build" {
  name         = "rails-store-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "ap-south-2"
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-south-2.amazonaws.com/store-app"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }
}