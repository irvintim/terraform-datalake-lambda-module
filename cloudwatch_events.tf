resource "aws_cloudwatch_event_rule" "this" {
  count               = length(local.event_schedule)
  name                = substr("${var.name}-${var.environment}-cloudwatch-event-${count.index}", 0, 64)
  description         = "Cloudwatch Event ${count.index} to Trigger Lambda ${var.name}-${var.environment}"
  schedule_expression = length(regexall("^[0-9]+$", local.event_schedule[count.index])) == 0 ? local.event_schedule[count.index] : "rate(${local.event_schedule[count.index]} minutes)"
}

resource "aws_cloudwatch_event_target" "this" {
  count     = length(local.event_schedule)
  rule      = aws_cloudwatch_event_rule.this[count.index].name
  target_id = "${var.name}-${var.environment}-${count.index}"
  arn       = aws_lambda_function.this.arn
  input = jsonencode(merge(
    {
      S3_BUCKET       = local.s3_bucket
      SSM_CONFIG_PATH = var.ssm_config_path
    },
    local.lambda_input[count.index]
  ))
}

resource "aws_lambda_permission" "this" {
  count         = length(local.event_schedule)
  statement_id  = "AllowExecutionFromCloudWatch-${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this[count.index].arn
}