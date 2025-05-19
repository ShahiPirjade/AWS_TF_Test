# 1St we need to create an archive file data resource which will help us to take the content of this lambda funtion folder and create an archive and put it in the same folder 
# as .zip archive
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "index.py"
  output_path = "${path.module}/lambda_function_payload.zip"
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy

resource "aws_iam_policy" "policy" {
  name        = "${var.app_env}-test_policy"
  path        = "/"
  description = "${var.app_env}- My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
#Statement which allow lambda fn to get and put in the s3 bucket
      {
        Action = [
          #"ec2:Describe*",
	  "s3:PutObject",
	  "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.bucket.arn}" #Defined this bucket in sqs.tf file
      },
#Statement which allow lambda fn permission to work with SQS
{
        Action = [
	  "sqs:ReceiveMessage",
	  "sqs:DeleteMessage",
	  "sqs:GetQueueAttributes"
        ]
        Effect   = "Allow"
        Resource = "${aws_sqs_queue.queue.arn}" #Defined thisSQS queue in sqs.tf file
      },
#Statement which allow lambda fn to send logs for Observability
{
        Action = [
	  "logs:CreateLogGroup",
	  "logs:CreateLogStream",
	  "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Define Lambda Funtion Role https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/resources/iam_role

resource "aws_iam_role" "test_role" {
  name = "${var.app_env}-lambda-test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Env = "QA"
  }
}

# Attaching the above "..lambda test role" to policy https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.policy.arn
}

#Lambda function declaration - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function


resource "aws_lambda_function" "sqs_processor" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "${path.module}/lambda_function_payload.zip"
  function_name = "${var.app_env}-lambda_function_name"
  role          = aws_iam_role.test_role.arn
  handler       = "index.lambda_handler" #1st method of lambda fn will be executed as soon as lambda fn is triggered 
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime 	= "python3.12"
}


