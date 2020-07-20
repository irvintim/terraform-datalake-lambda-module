locals {
  lambda_source      = var.lambda_source == "" ? "${path.root}/lambda_source" : var.lambda_source
  lambda_output_path = var.lambda_output_path == "" ? "${path.root}/${var.name}-${var.environment}.zip" : var.lambda_output_path
  tags               = {}
}

data "archive_file" "this" {
  source_dir  = local.lambda_source
  output_path = local.lambda_output_path
  type        = "zip"
}


resource "aws_lambda_function" "this" {
  description      = var.lambda_description
  filename         = data.archive_file.this.output_path
  function_name    = "${var.name}-${var.environment}"
  role             = aws_iam_role.this.arn
  handler          = var.lambda_handler
  source_code_hash = data.archive_file.this.output_base64sha256
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
}