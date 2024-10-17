variable "aws_region" {
  description = "AWS Region where resources will be deployed"
  type        = string
}

variable "key_pair" {
  description = "The AWS key pair name for SSH access"
  type        = string
}

variable "key_pair_path" {
  description = "Path to the private key file"
  type        = string
}

variable "bucket_name" {
  description = "The S3 bucket name for listing contents"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
