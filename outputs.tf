output "sns_standard_topic_arn" {
  value = aws_sns_topic.user_updates.arn
}

output "sns_fifo_topic_arn" {
  value = aws_sns_topic.user_updates_fifo.arn
}

output "sqs_queue_arn" {
  value = aws_sqs_queue.terraform_queue.arn 
}

output "dlq_queue_arn" {
  value = aws_sqs_queue.terraform_queue_deadletter.arn
}
