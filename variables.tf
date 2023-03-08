variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "lambda_function_name" {
  type    = string
  default = "purge_s3_bucket"
}

variable "lambda_schedule" {
  type    = string
  default = "cron(0 0 23 ? * SUN *)"
}

