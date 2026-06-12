resource "aws_cloudwatch_event_rule" "pipeline_failed" {
  name = "pipeline-failed"

  event_pattern = jsonencode({
    source = ["aws.codepipeline"]

    "detail-type" = [
      "CodePipeline Pipeline Execution State Change"
    ]

    detail = {
      state = ["FAILED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "pipeline_target" {
  rule      = aws_cloudwatch_event_rule.pipeline_failed.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.alerts.arn
}

resource "aws_sns_topic_policy" "sns_eventbridge" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Sid    = "AllowEventBridge"
      Effect = "Allow"

      Principal = {
        Service = "events.amazonaws.com"
      }

      Action   = "sns:Publish"
      Resource = aws_sns_topic.alerts.arn
    }]
  })
}