import boto3
import os

def download_tfvars(bucket_name, tfvars_key, download_path="terraform.tfvars"):
    s3 = boto3.client('s3')
    s3.download_file(bucket_name, tfvars_key, download_path)
    print(f"Downloaded {tfvars_key} from bucket {bucket_name} to {download_path}")

if __name__ == "__main__":
    bucket_name = 'one2nterraformtfvarsfile'
    tfvars_key = 'terraform.tfvars'
    download_tfvars(bucket_name, tfvars_key)
