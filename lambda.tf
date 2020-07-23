resource "aws_lambda_function" "this" {
  description      = var.lambda_description
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.name}-${var.environment}"
  role             = aws_iam_role.this.arn
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = var.lambda_runtime
  memory_size      = var.lambda_memory_size
  timeout          = var.lambda_timeout
  vpc_config {
    security_group_ids = var.lambda_security_group_ids
    subnet_ids         = var.lambda_subnet_ids
  }
  environment {
    variables = var.lambda_environment_vars
  }
  tags = merge(
    local.tags,
    var.global_tags,
    {
      "Environment" = var.environment,
      "Name"        = "${var.name}-${var.environment}"
    }
  )
  depends_on = [aws_cloudwatch_log_group.this]
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/aws/lambda/${var.name}-${var.environment}"
  tags = merge(
    local.tags,
    var.global_tags,
    {
      "Environment" = var.environment,
      "Name"        = "${var.name}-${var.environment}"
    }
  )
}