#Role
data "aws_iam_policy_document" "this_assume_role" {
  statement {
    actions    = [
      "sts:AssumeRole"
    ]
    principals = {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "lambda-${name}-${environment}-role"
  path               = "/service-role/"
  assume_role_policy = "${data.aws_iam_policy_document.this_assume_role.json}"
}

#Policies
data "aws_iam_policy_document" "this" {
  statement {
    sid       = "CreateLogGroupAllow"
    actions   = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
  statement {
    sid       = "CreateLogStreamPutEvents"
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name}-${var.environment}:*"
    ]
  }
  statement {
    sid       = "S3GetPut"
    actions   = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket}"
    ]
  }
}

resource "aws_iam_policy" "this" {
  name   = "lambda-${var.name}-${var.environment}-policy"
  policy = "${data.aws_iam_policy_document.this.json}"
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = "${aws_iam_role.this.name}"
  policy_arn = "${aws_iam_policy.this.arn}"
}
