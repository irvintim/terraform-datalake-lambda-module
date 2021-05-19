resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  tags = merge(
    local.tags,
    var.global_tags,
    {
      "Environment" = var.environment,
      "Name"        = "${aws_lambda_function.this.function_name}-ERRORS"
    }
  )
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

resource "aws_cloudwatch_metric_alarm" "s3_anomaly_detection" {
  count  = var.s3_bucket != null  ? 1 : 0
  alarm_name                = "${var.s3_bucket}-S3-missing-data"
  comparison_operator       = "LessThanLowerThreshold"
  evaluation_periods        = "1"
  threshold_metric_id       = "ad1"
  alarm_description         = "This metric monitors ${var.s3_bucket} for gaps in incoming data"
  insufficient_data_actions = []
  alarm_actions = ["arn:aws:sns:us-east-1:547715215608:datawarehouse-lambda-alarms-noreport"] #TODo Update to Prod SNS Topic
  datapoints_to_alarm = "1"
  actions_enabled = true
  ok_actions = []
  treat_missing_data = "missing"


  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.anomaly_band_width})"
    label       = "NumberOfObjects (expected)"
    return_data = true
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "NumberOfObjects"
      namespace   = "AWS/S3"
      period      = "86400"
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        StorageType = "AllStorageTypes"
        BucketName = var.s3_bucket
      }
    }
  }
}