locals {
  lambda_source      = var.lambda_source == "" ? "${path.root}/lambda_source" : var.lambda_source
  lambda_output_path = var.lambda_output_path == "" ? "${path.root}/${var.name}-${var.environment}.zip" : var.lambda_output_path
  tags               = {}
}

