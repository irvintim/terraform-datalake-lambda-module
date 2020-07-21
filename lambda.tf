resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
}

data "archive_file" "dir_hash_zip" {
  type        = "zip"
  source_dir  = "${var.lambda_source}/"
  output_path = "${path.module}/dir_hash_zip"
}

resource "null_resource" "install_python_dependencies" {
  triggers = {
    requirements = sha1(file("${var.lambda_source}/requirements.txt"))
    dir_hash     = data.archive_file.dir_hash_zip.output_base64sha256
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/py_pkg.sh"

    environment = {
      source_code_path = var.lambda_source
      path_cwd         = path.cwd
      path_module      = path.module
      runtime          = var.lambda_runtime
      function_name    = "${var.name}-${var.environment}"
      random_string    = random_string.name.result
    }
  }
}

data "archive_file" "lambda_zip" {
  depends_on  = [null_resource.install_python_dependencies]
  type        = "zip"
  source_dir  = "${path.cwd}/lambda_pkg_${random_string.name.result}/"
  output_path = var.lambda_output_path
}

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
}