resource "aws_cloudwatch_event_rule" "this" {
  name                = "${var.name}-${var.environment}-cloudwatch-event"
  description         = "Cloudwatch Event to Trigger Lambda ${var.name}-${var.environment}"
  schedule_expression = "rate(${var.event_schedule_minutes} minutes)"
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "${var.name}-${var.environment}"
  arn       = aws_lambda_function.this.arn
  input = jsonencode(merge(
    {
      S3_BUCKET       = var.s3_bucket
      SSM_CONFIG_PATH = var.ssm_config_path
    },
    var.lambda_input
  ) )
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}