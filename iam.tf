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
  name               = "lambda-${var.name}-${var.environment}-role"
  path               = "/service-role/"
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
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
  statement {
    sid = "CreateLogStreamPutEvents"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name}-${var.environment}:*"
    ]
  }
  statement {
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
      "arn:aws:s3:::${var.s3_bucket}",
      "arn:aws:s3:::${var.s3_bucket}/*"
    ]
  }
  statement {
    sid = "S3CreateBucket"
    actions = [
      "s3:CreateBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}"
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
    sid = "SSMGetParametersByPath"
    actions = [
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_config_path}"
    ]
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
