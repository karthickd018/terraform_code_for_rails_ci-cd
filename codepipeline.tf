resource "aws_codepipeline" "rails_pipeline" {

  name     = "rails-store-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  #################################
  # SOURCE
  #################################

  stage {
    name = "Source"

    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"
      provider = "S3"
      version  = "1"

      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket             = aws_s3_bucket.source_bucket.bucket
        S3ObjectKey          = "source.zip"
        PollForSourceChanges = "true"
      }
    }
  }

  #################################
  # BUILD
  #################################

  stage {
    name = "Build"

    action {
      name     = "Build"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"

      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.rails_build.name
      }
    }
  }

  #################################
  # DEPLOY
  #################################

  stage {
    name = "Deploy"

    action {
      name     = "DeployToECS"
      category = "Deploy"
      owner    = "AWS"
      provider = "ECS"
      version  = "1"

      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = "rails-store-cluster"
        ServiceName = "rails-store-service"
        FileName    = "imagedefinitions.json"
      }
    }
  }
}