resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${aws_lambda_function.this.function_name}"
  tags = merge(
    local.tags,
    var.global_tags,
    {
      "Environment" = var.environment,
      "Name"        = "${aws_lambda_function.this.function_name}-ERRORS"
    }
  )
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  name           = "ERROR-Logs"
  pattern        = "\"[ERROR]\""
  log_group_name = aws_cloudwatch_log_group.this.name

  metric_transformation {
    name      = aws_lambda_function.this.function_name
    namespace = "INOC/Lambda-Error-Count"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "this" {
  count               = var.sns_topic == "" ? 0 : 1
  alarm_name          = "${aws_lambda_function.this.function_name}-ERRORS"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_lambda_function.this.function_name
  namespace           = "INOC/Lambda-Error-Count"
  period              = "10"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "Monitors for ERROR messages in Lambda function Cloudwatch Logs"
  alarm_actions       = [var.sns_topic]
  tags = merge(
    local.tags,
    var.global_tags,
    {
      "Environment" = var.environment,
      "Name"        = "${aws_lambda_function.this.function_name}-ERRORS"
    }
  )
}