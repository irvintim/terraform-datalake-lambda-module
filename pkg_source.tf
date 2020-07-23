resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
}

data "archive_file" "src_dir_hash_zip" {
  type        = "zip"
  source_dir  = "${var.lambda_source}/"
  output_path = "${path.module}/build/src_dir_hash_zip"
}

data "archive_file" "dest_dir_hash_zip" {
  type        = "zip"
  source_dir  = "${path.cwd}/lambda_pkg_${random_string.name.result}/"
  output_path = "${path.module}/build/dst_dir_hash_zip"
}

resource "null_resource" "install_python_dependencies" {
  triggers = {
    requirements  = sha1(file("${var.lambda_source}/requirements.txt"))
    src_dir_hash  = data.archive_file.src_dir_hash_zip.output_base64sha256
    dest_dir_hash = data.archive_file.dest_dir_hash_zip.output_base64sha256
    random_string = sha1(random_string.name.result)
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
