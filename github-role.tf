resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-rails-store"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:karthickd018/rails-store:*"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy" "github_actions_policy" {
  name = "github-actions-policy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:GetObject"
        ]

        Resource = [
          "${aws_s3_bucket.source_bucket.arn}/*"
        ]
      },

      {
        Effect = "Allow"

        Action = [
          "codepipeline:StartPipelineExecution"
        ]

        Resource = "*"
      }
    ]
  })
}