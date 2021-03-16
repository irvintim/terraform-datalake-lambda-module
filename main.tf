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
  tags = {}
  event_schedule = try(
          [tostring(var.event_schedule)],
          tolist(var.event_schedule)
          )
  lambda_input = try(
          [tomap(var.lambda_input)],
          [for x in tolist(var.lambda_input) : tomap(x)]
          )
  s3_bucket = var.s3_bucket != null ? var.s3_bucket : "NO_BUCKET"
}

resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
}

