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
  tags                 = {}
  event_schedule       = regex("^[0-9]+$", var.event_schedule) == "" ? var.event_schedule : "rate(${var.event_schedule} minutes)"
  snowpipe_sqs         = "arn:aws:sqs:us-east-1:988245671738:sf-snowpipe-AIDA6MGAIH45F4YAWF7M2-5fUi1EqYJh47swW-cOaPtA"
  snowpipe_external_id = "DTA64387_SFCRole=2_jcgDNE16q+uusaNErns8Z8VmYIo="
}

resource "random_string" "name" {
  length  = 4
  special = false
  upper   = false
}

