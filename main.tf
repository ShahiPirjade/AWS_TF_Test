# Case1 :Createed sns topic with type=Standard, Subscription=Email and Encrypted it .
resource "aws_sns_topic" "user_updates" {
  name = "aws-sns-topic-case1"  # Updating the name from standard name in TF document as "user-updates-topic"
  kms_master_key_id = "alias/aws/sns"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.user_updates.arn # here value will be automatically getting updated, once terraform creates a topic
  protocol  = "email"  #updating from sqs to email as protocol
  endpoint  = "pirjadeshahistha@gmail.com"		# updating to email id from aws_sqs_queue.user_updates_queue.arn
}

#Case 2 : Created a SQS with type=FIFO and Encrypted.
# SQS Queue

# Dead-letter queue (DLQ) # Defining DLQ as in the standard TF file its mentioned and if i dont use it throws up an error. 
resource "aws_sqs_queue" "terraform_queue_deadletter" {
  name                        = "terraform-example-deadletter-queue.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  kms_master_key_id           = "alias/aws/sqs"
}

resource "aws_sqs_queue" "terraform_queue" {
  name                      = "terraform-example-queue.fifo"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.terraform_queue_deadletter.arn}\",\"maxReceiveCount\":4}"
  fifo_queue                  = true
  content_based_deduplication = true
  kms_master_key_id           = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300
  tags = {
    Environment = "QA"  # Upating the value to QA from "production"
  }
}

resource "aws_sqs_queue_policy" "test" {
  queue_url = "${aws_sqs_queue.terraform_queue.id}" #updating the resource name from aws_sqs_queue.q.id

#TASK3 Reference - https://registry.terraform.io/providers/hashicorp/aws/2.34.0/docs/resources/sqs_queue_policy
 policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sns_topic.user_updates.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.user_updates.arn}"
        }
      }
    }
  ]
}
POLICY
}

# Case3 :Created SNS topic with type=FIFO and Encrypted it with subscription SQS

resource "aws_sns_topic" "user_updates_fifo" {
  name = "aws-sns-topic-case3.fifo"  # Updating the name from standard name in TF document as "user-updates-topic"
  fifo_topic                  = true
  content_based_deduplication = true
  kms_master_key_id = "alias/aws/sns"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

# Allow SNS to send messages to SQS

# Subscription: SNS → SQS
resource "aws_sns_topic_subscription" "fifo_sqs_sub" {
  topic_arn = aws_sns_topic.user_updates_fifo.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.terraform_queue.arn
  raw_message_delivery = true
}
