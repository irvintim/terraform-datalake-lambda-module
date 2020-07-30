locals {
  requirements_hash = fileexists("${var.lambda_source}/requirements.txt") ? filesha256("${var.lambda_source}/requirements.txt") : 0
}
resource "null_resource" "install_python_dependencies" {
  triggers = {
    requirements  = local.requirements_hash
    layer_zipfile = data.archive_file.layer_zip.output_base64sha256
    runtime       = var.lambda_runtime
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/layer_pkg.sh"

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

data "null_data_source" "wait_for_install_python_dependencies" {
  inputs = {
    install_python_dependencies_id = null_resource.install_python_dependencies.id
    source_dir                     = "${path.cwd}/layer_pkg_${random_string.name.result}/"
  }
}

data "archive_file" "layer_zip" {
  depends_on  = [null_resource.install_python_dependencies]
  type        = "zip"
  source_dir  = data.null_data_source.wait_for_install_python_dependencies.outputs["source_dir"]
  output_path = var.layer_zipfile
}
