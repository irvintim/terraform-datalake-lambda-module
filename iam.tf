#Role
data "aws_iam_policy_document" "this_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = substr("lambda-${var.name}-${var.environment}-role", 0, 64)
  path               = "/lambda-role/"
  assume_role_policy = data.aws_iam_policy_document.this_assume_role.json
}

#Policies
data "aws_iam_policy_document" "this" {
  statement {
    sid = "NetworkInterface"
    actions = [
      "EC2:CreateNetworkInterface",
      "EC2:DescribeNetworkInterfaces",
      "EC2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
  statement {
    sid = "CreateLogGroupAllow"
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
  statement {
    sid = "CreateLogStreamPutEvents"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name}-${var.environment}:*"
    ]
  }
  statement {
    sid = "S3ListBucket"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "DDMDescribeParameters"
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid = "SSMGetParametersByPath"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_config_path}",
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_config_path}*"
    ]
  }
  dynamic "statement" {
    for_each = [var.s3_bucket]
    content {
      sid = "S3GetPut"
      actions = [
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectTagging",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectTagging",
        "s3:DeleteObject",
        "s3:ListBucketMultipartUploads",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts"
      ]
      resources = [
        "arn:aws:s3:::${statement}",
        "arn:aws:s3:::${statement}/*"
      ]
    }
  }
  dynamic "statement" {
    for_each = [var.s3_bucket]
    content {
      sid = "S3CreateBucket"
      actions = [
        "s3:CreateBucket"
      ]
      resources = [
        "arn:aws:s3:::${statement}"
      ]
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "lambda-${var.name}-${var.environment}-policy"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

data "aws_iam_policy_document" "snowpipe" {
  dynamic "statement" {
    for_each = [var.s3_bucket]
    content {
      sid = "SnowpipeGetS3"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion"
      ]
      resources = [
        "arn:aws:s3:::${aws_s3_bucket.dest_bucket.id}/*",
      ]
    }
  }
  dynamic "statement" {
    for_each = [var.s3_bucket]
    content {
      sid = "SnowpipeListS3"
      actions = [
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::${aws_s3_bucket.dest_bucket.id}"
      ]
    }
  }
}

data "aws_iam_policy_document" "snowpipe_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::988245671738:user/gl4u-s-v2su2085"
      ]
    }
    condition {
      test     = "StringEquals"
      values   = [local.snowpipe_external_id]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role" "snowpipe" {
  name               = substr("snowpipe-${var.name}-${var.environment}-role", 0, 64)
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.snowpipe_assume_role.json
}

resource "aws_iam_policy" "snowpipe" {
  name   = "snowpipe-${var.name}-${var.environment}-policy"
  policy = data.aws_iam_policy_document.snowpipe.json
}

resource "aws_iam_role_policy_attachment" "snowpipe" {
  role       = aws_iam_role.snowpipe.name
  policy_arn = aws_iam_policy.snowpipe.arn
}