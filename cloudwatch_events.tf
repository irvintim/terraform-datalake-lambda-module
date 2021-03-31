resource "aws_cloudwatch_event_rule" "this" {
  count               = var.event_schedule != "" ? 1 : 0
  name                = substr("${var.name}-${var.environment}-cloudwatch-event", 0, 64)
  description         = "Cloudwatch Event to Trigger Lambda ${var.name}-${var.environment}"
  schedule_expression = local.event_schedule
  tags = merge(
    local.tags,
    var.global_tags,
    {
      "Environment" = var.environment,
      "Name"        = "${var.name}-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_event_target" "this" {
  count     = var.event_schedule != "" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.this[0].name
  target_id = "${var.name}-${var.environment}"
  arn       = aws_lambda_function.this.arn
  input = jsonencode(merge(
    {
      S3_BUCKET       = var.s3_bucket
      SSM_CONFIG_PATH = var.ssm_config_path
    },
    var.lambda_input
  ))
}

resource "aws_lambda_permission" "this" {
  count         = var.event_schedule != "" ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[0].arn
}