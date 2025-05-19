import json
import os
import logging
import boto3

# Initialize logger
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function that processes messages from SQS safely.
    It skips empty or malformed messages and logs all activity.
    """
    for record in event.get('Records', []):
        raw_body = record.get('body', '').strip()
        logger.info(f"📦 Received raw SQS message body: {repr(raw_body)}")

        if not raw_body:
            logger.warning("⚠️ Empty message body — skipping.")
            continue

        try:
            message = json.loads(raw_body)
            logger.info(f"✅ Parsed message: {message}")
        except json.JSONDecodeError as json_err:
            logger.error(f"❌ JSON decode error: {json_err} — skipping this message.")
            continue

        # Now extract and log the order fields
        order_id = message.get('Order_id')
        amount = message.get('Amount')
        item = message.get('Item')

        logger.info(f"🧾 Order ID: {order_id}, Amount: {amount}, Item: {item}")

    return {
        "statusCode": 200,
        "message": "All messages processed"
    }
   