import boto3
from datetime import datetime

def handler(event, context):
    print("----------------------------------")
    print("Executed: ", datetime.now().strftime("%H:%M:%S"))
    print(context.function_name)
    print(event.s3_bucket_name)

    return {
        "statusCode": 200
    }