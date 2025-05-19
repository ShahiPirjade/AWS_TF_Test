import boto3
import json

# Initialize the SQS client
sqs = boto3.client('sqs', region_name='us-east-2')  # Replace with your AWS region

# Replace with your actual SQS queue URL
queue_url = "https://sqs.us-east-2.amazonaws.com/616904086648/task3-lambda-sqss3-event-notification-queue"

# Create an order message
order_data = {
    "Order_id": "001",
    "Amount": 129.99,
    "Item": "Open AI subscription"
}

try:
    # Send message to SQS
    response = sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(order_data)  # ✅ Proper JSON string
    )

    print("✅ Message sent successfully!")
    print("🪪 Message ID:", response['MessageId'])

except Exception as e:
    print("❌ Failed to send message:", str(e))
