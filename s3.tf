resource "aws_s3_bucket" "dest_bucket" {
  count  = len(var.s3_bucket) > 0 ? 1 : 0
  bucket = var.s3_bucket
  acl    = "private"

  tags = merge(
    local.tags,
    var.global_tags,
    {
      "Environment" = var.environment,
      "Name"        = "${var.name}-${var.environment}"
  })
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = len(var.s3_bucket) > 0 ? 1 : 0
  bucket = aws_s3_bucket.dest_bucket[0].id

  queue {
    queue_arn = local.snowpipe_sqs
    events    = ["s3:ObjectCreated:*"]
  }
}