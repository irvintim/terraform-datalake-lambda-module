terraform-datalake-lambda-module
===========

This module will install a lambda job in the indicated VPC, and configured with permissions to receive data from an external source (likely an API), and put that data into an S3 bucket.  CloudWatch Events have permission to trigger this event.  CloudWatch Logs permissions allow Lambda to send logs.  Other permissions can be added by the calling terraform code.


```hcl-terraform
module terraform-datalake-lambda {
    # Required Parameters
    name = "lambda_function_name"
    environment = "environment_name"
    lambda_description = "Description of the Lambda Function"
    lambda_runtime = "python3.8"
    s3_bucket = "mybucket"
    event_schedule_minutes = 60

   # Optional Parameters
    lambda_source = "/usr/src/src_code" 
    lambda_output_path = "/tmp/source_output.zip" 
    lambda_handler = "lambda_function.lambda_handler" 
    lambda_environment_vars = {
       "START_TIME" = "-1h@h",
       "END_TIME" = "-0h@h"
    } 
    lambda_input = {
        "s3-subdirectory" = "Reports",
        "timezone" = "naive"
    }
    lambda_memory_size = 128 
    lambda_timeout = 3 
    lambda_security_group_ids = ["sg-1234567"] 
    lambda_subnet_ids = ["subnet-1234567", "subnet-4567890"] 
    global_tags = {"Client" = "MyCustomer"} 
}
```

where:

| Variable | Description | Default/Required |
|----------|-------------|---------|
| name | Name of Lambda function | Required |
| environment | Environment | Required |
| lambda_source | Path to the top of the Lambda code tree.  | `lambda_source` in root of terraform code. | 
| lambda_output_path | Path to the directory where zipped Lambda code will be dropped. | `${var.name}-${var.environment}.zip` in root of terraform code. |
| lambda_description | Description of the Lambda Function | Required |
| lambda_handler | Lamda Function handler | `lambda_function.lambda_handler` |
| lambda_runtime | Runtime and version | `python3.8` |
| lambda_environment_vars | Map of environment variables to pass top Lambda function | {} |
| lambda_memory_size | Amount of RAM the Lambda Function can use | `128` |
| lambda_timeout | Amount of time the Lambda Function has to run | `3` |
| lambda_security_group_ids | Security Group(s) associated with the Lambda Function | [] |
| lambda_subnet_ids | Subnets the Lambda Function is associated with | [] |
| s3_bucket | S3 bucket to receive data from Lambda Function | Required |
| global_tags | Global tags to add to all resources created by this module | {} |
