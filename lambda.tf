resource "aws_lambda_function" "this" {
  description       = var.lambda_description
  s3_bucket         = var.lambda_s3_bucket
  s3_key            = var.lambda_s3_bucket
  s3_object_version = var.lambda_s3_version
  function_name     = "${var.name}-${var.environment}"
  role              = aws_iam_role.this.arn
  handler           = var.lambda_handler
  runtime           = var.lambda_runtime
  memory_size       = var.lambda_memory_size
  timeout           = var.lambda_timeout
  layers            = aws_lambda_layer_version.this.*.arn
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
}

resource "aws_lambda_layer_version" "this" {
  count               = var.lambda_layer_s3_bucket != null ? 1 : 0
  layer_name          = "${var.name}-layer"
  license_info        = "various"
  description         = "Layer of modules not available in stock Lambda"
  s3_bucket           = var.lambda_layer_s3_bucket
  s3_key              = var.lambda_layer_s3_key
  s3_object_version   = var.lambda_layer_s3_version
  compatible_runtimes = [var.lambda_runtime]
}

