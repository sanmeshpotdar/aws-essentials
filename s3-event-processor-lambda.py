import json
import boto3
import os
import logging
from datetime import datetime
from botocore.exceptions import ClientError

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

# Get environment variables
TABLE_NAME = os.environ['DYNAMODB_TABLE']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def process_data(data):
    """Process the input data"""
    # Example processing: capitalize keys and multiply numeric values by 2
    processed = {}
    for key, value in data.items():
        if isinstance(value, (int, float)):
            processed[key.upper()] = value * 2
        else:
            processed[key.upper()] = value.upper() if isinstance(value, str) else value
    return processed

def store_in_dynamodb(item):
    """Store item in DynamoDB"""
    table = dynamodb.Table(TABLE_NAME)
    try:
        response = table.put_item(Item=item)
        logger.info(f"Successfully stored item in DynamoDB: {json.dumps(item)}")
    except ClientError as e:
        logger.error(f"Error storing item in DynamoDB: {e.response['Error']['Message']}")
        raise

def send_sns_notification(message):
    """Send SNS notification"""
    try:
        response = sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=json.dumps({'default': json.dumps(message)}),
            MessageStructure='json'
        )
        logger.info(f"Successfully sent SNS notification: {json.dumps(message)}")
    except ClientError as e:
        logger.error(f"Error sending SNS notification: {e.response['Error']['Message']}")
        raise

def lambda_handler(event, context):
    """Main Lambda function handler"""
    try:
        # Get the S3 bucket and key from the event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        logger.info(f"Processing file {key} from bucket {bucket}")

        # Get the file content from S3
        response = s3.get_object(Bucket=bucket, Key=key)
        file_content = response['Body'].read().decode('utf-8')
        data = json.loads(file_content)

        # Process the data
        processed_data = process_data(data)

        # Add metadata
        processed_data['TIMESTAMP'] = datetime.now().isoformat()
        processed_data['SOURCE_FILE'] = f"s3://{bucket}/{key}"

        # Store in DynamoDB
        store_in_dynamodb(processed_data)

        # Send SNS notification
        notification_message = {
            "message": "Data processed successfully",
            "source_file": f"s3://{bucket}/{key}",
            "timestamp": processed_data['TIMESTAMP']
        }
        send_sns_notification(notification_message)

        return {
            'statusCode': 200,
            'body': json.dumps('Processing completed successfully')
        }
    except Exception as e:
        logger.error(f"Error processing data: {str(e)}")
        # Send error notification
        error_message = {
            "message": "Error processing data",
            "error": str(e),
            "source_file": f"s3://{bucket}/{key}" if 'bucket' in locals() and 'key' in locals() else "Unknown"
        }
        send_sns_notification(error_message)
        raise
