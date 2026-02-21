import boto3
import json
import os
from datetime import datetime
import uuid

# Environment variables for the SNS Topic ARN and S3 Bucket Name
SNS_TOPIC_ARN = 'arn:aws:sns:us-west-2:800762100652:topic1'
S3_BUCKET_NAME = 's3-json-receive'
sns_client = boto3.client('sns')
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    # Iterate over each message record received from SQS
    for record in event['Records']:
        message_body = record['body']
        message_id = record['messageId']
        timestamp = datetime.now().isoformat()
        
        # Data structure for storage and notification
        message_data = {
            'message-id': message_id,
            'body': message_body,
            'timestamp': timestamp
        }
        
        # 1. Publish message to SNS topic for email notification
        try:
            sns_response = sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=json.dumps(message_data, indent=4),
                Subject='SQS Message Notification'
            )
            print(f"Message sent to SNS: {json.dumps(sns_response, indent=4)}")
        except Exception as e:
            print(f"Error publishing to SNS: {e}")
            # Handle failure as needed

        # 2. Store the message data in S3
        try:
            # Use a unique filename, e.g., messageId or timestamp
            s3_filename = f"sqs-messages/{message_id}.json"
            s3_client.put_object(
                Body=json.dumps(message_data, indent=4),
                Bucket=S3_BUCKET_NAME,
                Key=s3_filename
            )
            print(f"Message stored in S3: s3://{S3_BUCKET_NAME}/{s3_filename}")
        except Exception as e:
            print(f"Error storing in S3: {e}")
            # Handle failure as needed
            
    return {'statusCode': 200, 'body': json.dumps('Messages processed')}

