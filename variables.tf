variable "name" {
  type        = string
  description = "Name of Lambda function"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "global_tags" {
  type        = map(string)
  description = "Global tags to add to all resources created by this module"
  default     = {}
}

variable "lambda_s3_bucket" {
  type        = string
  description = "S3 bucket with lambda code, ignored if lambda_source is defined"
  default     = null
}

variable "lambda_s3_key" {
  type        = string
  description = "S3 key with lambda code, ignored if lambda_source is defined"
  default     = null
}

variable "lambda_s3_version" {
  type        = string
  description = "S3 object version with lambda code, ignored if lambda_source is defined"
  default     = null
}

variable "lambda_layer_s3_bucket" {
  type        = string
  description = "S3 bucket with lambda layer code, ignored if lambda_source is defined"
  default     = null
}

variable "lambda_layer_s3_key" {
  type        = string
  description = "S3 key with lambda layer code, ignored if lambda_source is defined"
  default     = null
}

variable "lambda_layer_s3_version" {
  type        = string
  description = "S3 object version with lambda layer code, ignored if lambda_source is defined"
  default     = null
}

variable "lambda_description" {
  type        = string
  description = "Description of the Lambda Function"
}

variable "lambda_handler" {
  type        = string
  description = "Lamda function handler"
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  type        = string
  description = "Runtime and version"
  default     = "python3.8"
}

variable "lambda_environment_vars" {
  type        = map(string)
  description = "Map of environment variables to pass top Lambda function"
  default     = {}
}

variable "lambda_memory_size" {
  type        = number
  description = "Amount of RAM the Lambda Function can use"
  default     = 128
}

variable "lambda_timeout" {
  type        = number
  description = "Amount of time the Lambda Function has to run"
  default     = 3
}

variable "lambda_security_group_ids" {
  type        = list(string)
  description = "Security Group(s) associated with the Lambda Function"
  default     = []
}

variable "lambda_subnet_ids" {
  type        = list(string)
  description = "Subnets the Lambda Function is associated with"
  default     = []
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket to receive data from Lambda Function"
}

variable "ssm_config_path" {
  type        = string
  description = "SSM Path for configuration fro this lambda"
}

variable "lambda_input" {
  type        = any
  description = "Converted to JSON Cloudwatch Event Input Document for Lambda"
  default     = {}
}

variable "event_schedule" {
  type        = any
  description = "How often to trigger the Lambda (either minutes, or cron)"
}

variable "sns_topic" {
  type        = string
  description = "SNS Topic to send alarms to (if defined)"
  default     = ""
}

variable "cloudwatch_logs_retention_in_days" {
  type        = number
  default     = null
  description = "How long to retain Cloudwatch Logs for this function, null is indefinite"
}