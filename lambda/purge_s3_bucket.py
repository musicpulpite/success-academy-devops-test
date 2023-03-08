import boto3
from datetime import datetime

def handler(event, context):
    status_code = 200
    bucket_name = event["s3_bucket_name"]
    client = boto3.client("s3")

    list_objects_res = client.list_objects(Bucket=bucket_name)

    if "Contents" in list_objects_res:
        for obj in list_objects_res["Contents"]:
            key = obj["Key"]
            print(f"Deleting: {bucket_name}.{key}")
            client.delete_object(Bucket=bucket_name, Key=key)
    
    # Check again to be sure
    list_objects_res_redux = client.list_objects(Bucket=bucket_name)

    if "Contents" in list_objects_res_redux:
        if len(list_objects_res_redux["Contents"]) > 0:
            obj_keys = [obj["Key"] for obj in list_objects_res_redux["Contents"]]
            err_msg = "Failed to delete: " + str(obj_keys)
            print(err_msg)
            raise Exception(err_msg)
    

    return {
        "statusCode": status_code
    }