data "archive_file" "src_dir_hash_zip" {
  type        = "zip"
  source_dir  = "${var.lambda_source}/"
  output_path = "${path.module}/build/src_dir_hash_zip"
}

resource "null_resource" "package_python_code" {
  triggers = {
    src_dir_hash   = data.archive_file.src_dir_hash_zip.output_base64sha256
    random_trigger = filesha256("${var.lambda_source}/.randomtrigger")
    random_string  = sha1(random_string.name.result)
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/py_pkg.sh"

    environment = {
      source_code_path = var.lambda_source
      path_cwd         = path.cwd
      random_string    = random_string.name.result
    }
  }
}

data "null_data_source" "wait_for_package_python_code" {
  inputs = {
    install_python_dependencies_id = null_resource.package_python_code.id
    source_dir = "${path.cwd}/lambda_pkg_${random_string.name.result}/"
  }
}

data "archive_file" "lambda_zip" {
  depends_on = [null_resource.package_python_code]
  type        = "zip"
  source_dir  = data.null_data_source.wait_for_package_python_code.outputs["source_dir"]
  output_path = var.lambda_output_path
}
