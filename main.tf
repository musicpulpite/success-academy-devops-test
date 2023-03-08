# S3 bucket
resource "aws_s3_bucket" "reporting_bucket" {
  bucket = "success-academy-reporting-bucket"
}

# S3 bucket access policies
resource "aws_s3_bucket_acl" "reporting_bucket_acl" {
  bucket = aws_s3_bucket.reporting_bucket.id
  access_control_policy {
    grant {
      grantee {
        type = "Group"
        uri  = "http://acs.amazonaws.com/groups/global/AllUsers"
      }
      permission = "WRITE"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

# ---------------------- Lambda IAM Role - Begin -----------------------
data "aws_iam_policy_document" "s3_modify_delete" {
  statement {
    sid = "allowS3"
    actions = [
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.reporting_bucket.arn]
  }
}

resource "aws_iam_policy" "s3_modify_delete" {
  name = "s3-modify-delete"

  policy = data.aws_iam_policy_document.s3_modify_delete.json
}

resource "aws_iam_role" "s3_admin_lambda_role" {
  name = "s3-admin-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2023-03-07"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_modify_delete" {
  name       = "s3_modify_delete_for_lambda"
  roles      = [aws_iam_role.s3_admin_lambda_role.name]
  policy_arn = aws_iam_policy.s3_modify_delete.arn
}

# ----------------------- Lambda IAM Role - End -----------------------------

# ----------------------- Lambda function definition - Begin ----------------
data "archive_file" "lambda_definition" {
  type        = "zip"
  source_file = "./lambda/purge_s3_bucket.py"
  output_path = "./lambda/${local.lambda_definition_name}.zip"
}

resource "aws_lambda_function" "purge_s3_bucket_lambda" {
  filename      = "./lambda/${local.lambda_definition_name}.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.s3_admin_lambda_role.arn

  source_code_hash = data.archive_file.lambda_definition.output_base64sha256

  runtime = "python3.9"
}

# EventBridge trigger
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "schedule-for-lambda"
  schedule_expression = var.lambda_schedule
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule = aws_cloudwatch_event_rule.lambda_schedule.name
  arn  = aws_lambda_function.purge_s3_bucket_lambda.arn

  target_id = aws_lambda_function.purge_s3_bucket_lambda.function_name

  input = jsonencode({
    s3_bucket_name = aws_s3_bucket.reporting_bucket.name
  })
}

resource "aws_lambda_permission" "cloudwatch_to_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.purge_s3_bucket_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

# ----------------------- Lambda function definition - End ----------------
