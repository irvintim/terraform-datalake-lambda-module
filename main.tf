provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

provider "archive" {
  version = "~> 1.3"
}

provider "random" {
  version = "~> 2.3"
}

locals {
  lambda_source      = var.lambda_source == "" ? "${path.root}/lambda_source" : var.lambda_source
  lambda_output_path = var.lambda_output_path == "" ? "${path.root}/${var.name}-${var.environment}.zip" : var.lambda_output_path
  tags               = {}
}

resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
}

