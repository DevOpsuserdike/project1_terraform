import boto3
import json
import logging
import csv
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Clients
ssm_client = boto3.client('ssm')
s3_client = boto3.client('s3')
sqs = boto3.client('sqs', region_name='us-west-2')

# Config
EC2_INSTANCE_ID = 'i-0e9aba0bbeca989c2'
SQS_QUEUE_URL = 'https://sqs.us-west-2.amazonaws.com/800762100652/sqs' # Make sure this is defined

def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Files must be in /tmp/ to be writable in Lambda
    local_csv_path = f"/tmp/{object_key}"
    
    # --- STEP 1: Notify EC2 via SSM ---
    try:
        command = f"aws s3 cp s3://{bucket_name}/{object_key} /home/ssm-user/{object_key}"
        response = ssm_client.send_command(
            InstanceIds=[EC2_INSTANCE_ID],
            DocumentName='AWS-RunShellScript',
            Parameters={'commands': [command]}
        )
        logger.info(f"Step 1 Success: SSM Command sent {response['Command']['CommandId']}")
    except Exception as e:
        logger.error(f"Step 1 Failed: SSM command failed. Error: {e}")
        return {"status": "failed", "step": 1}

    # --- STEP 2: Download, Convert, and Send to SQS ---
    try:
        # 1. Download the file from S3 to Lambda's local /tmp/
        s3_client.download_file(bucket_name, object_key, local_csv_path)

        # 2. Convert CSV to List of Dicts
        with open(local_csv_path, encoding='utf-8') as csvf:
            csv_reader = csv.DictReader(csvf)
            data = [row for row in csv_reader]

        # 3. Convert to JSON string (SQS MessageBody)
        file_content = json.dumps(data) 

        # 4. Send to SQS
        sqs_response = sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=file_content
        )
        logger.info(f"Step 2 Success: Message sent to SQS. ID: {sqs_response['MessageId']}")

    except Exception as e:
        logger.error(f"Step 2 Failed: Processing or SQS Error: {e}")
        return {"status": "failed", "step": 2}
    
    finally:
        # Clean up local file to save space
        if os.path.exists(local_csv_path):
            os.remove(local_csv_path)

    return {
        'statusCode': 200,
        'body': json.dumps('Workflow completed successfully')
    }