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

variable "lambda_source" {
  type        = string
  description = "Path to the top of the Lambda code tree.  Default is lambda_source in root of terraform code."
  default     = ""
}

variable "lambda_output_path" {
  type        = string
  description = "Path to the directory where zipped Lambda code will be dropped. Default is lambda_output_path in root of terraform code."
  default     = ""
}

variable "layer_zipfile" {
  type        = string
  description = "Zip file containing the Python modules to go in the layer"
  default     = "module-layer.zip"
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
  description = "Amount of time the Lambda FUnction has to run"
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
  type        = map(string)
  description = "Concverted to JSON Cloudwatch Event Input Docuement for Lambda"
  default     = {}
}

variable "event_schedule_minutes" {
  type        = number
  description = "How often to trigger the Lambda (minutes)"
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