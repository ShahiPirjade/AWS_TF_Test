variable "region" {
  description = "AWS region to deploy"
  default = "us-east-2"
}

variable "standard_sns_name" {
  description = "AWS region to deploy"
  default = "aws-sns-topic-case1"
}

variable "fifo_sns_name" {
  default = "aws-sns-topic-case3.fifo"
}

variable "subscription_email" {
  description = "Email address to subscribe to SNS"
  default     = "pirjadeshahistha@gmail.com"
}

variable "dlq_name" {
  default = "terraform-example-deadletter-queue.fifo"
}

variable "sqs_queue_name" {
  default = "terraform-example-queue.fifo"
}

variable "kms_sns_key_id" {
  default = "alias/aws/sns"
}

variable "kms_sqs_key_id" {
  default = "alias/aws/sqs"
}

variable "environment" {
  default = "QA"
} 