from flask import Flask, jsonify, request
import boto3
from botocore.exceptions import NoCredentialsError, ClientError
import os

app = Flask(__name__)

# Get bucket name from environment variable
BUCKET_NAME = os.environ.get('BUCKET_NAME')

if not BUCKET_NAME:
    raise ValueError("BUCKET_NAME environment variable is not set.")

# Initialize S3 client
s3_client = boto3.client('s3')

def list_s3_content(prefix=None):
    try:
        if prefix:
            # Fetch objects with the given prefix
            response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=prefix, Delimiter='/')
        else:
            # Fetch top-level objects
            response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Delimiter='/')

        directories = [obj['Prefix'] for obj in response.get('CommonPrefixes', [])]
        files = [obj['Key'] for obj in response.get('Contents', [])]
        return directories + files

    except NoCredentialsError:
        return "Credentials not available"
    except ClientError as e:
        return f"Error fetching S3 content: {e}"

@app.route('/list-bucket-content/', defaults={'prefix': ''}, methods=['GET'])
@app.route('/list-bucket-content/<path:prefix>', methods=['GET'])
def list_bucket_content(prefix):
    content = list_s3_content(prefix)
    if isinstance(content, str):
        return jsonify({"error": content}), 500
    return jsonify({"content": content})

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
