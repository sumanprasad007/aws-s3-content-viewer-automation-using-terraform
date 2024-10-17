# S3 Bucket Listing Service

This project provides an HTTP service that lists the content of an S3 bucket and a Terraform configuration to deploy it on AWS.

## Steps to Follow

### 1. Set up the Flask Application
1. Install Flask and Boto3:
    ```bash
    pip install flask boto3
    ```

2. Modify `app.py` to include your S3 bucket name:
    ```python
    BUCKET_NAME = 'your-bucket-name'
    ```

3. Run the Flask app:
    ```bash
    python app.py
    ```

    The service will be available at `http://localhost:5000/list-bucket-content`.

### 2. Set up Terraform and Deploy on AWS
1. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).

2. Modify `variables.tf` to include your AWS key-pair name:
    ```hcl
    variable "key_name" {
        default = "your-key-pair"
    }
    ```

3. Initialize and apply Terraform:
    ```bash
    terraform init
    terraform apply
    ```

4. After provisioning, access the Flask service using the public IP of the EC2 instance:
    ```
    http://<public-ip>:5000/list-bucket-content
    ```

### 3. Bonus: Handle Errors
1. The service returns a 500 error if S3 credentials are missing or invalid.
2. You can also add custom error handling for non-existing paths.

### 4. Cleanup
Don't forget to terminate the EC2 instance and clean up AWS resources to avoid unnecessary charges.
# aws-s3-content-viewer-automation-using-terraform
