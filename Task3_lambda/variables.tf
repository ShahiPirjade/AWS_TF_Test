variable "region" {
 default = "us-east-2"
 description = "Default Region for deployment"
}

variable "app_env" {
 default = "task3-lambda-sqs"
 description = "Common prefix for the terraform created resource for Task3 Lambda SQS" 
}
