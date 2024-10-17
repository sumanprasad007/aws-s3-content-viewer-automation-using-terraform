provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "allow_flask" {
  name        = "allow_flask_http"
  description = "Allow HTTP and SSH traffic for Flask app"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "s3_access_role" {
  name = "S3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = { Service = "ec2.amazonaws.com" },
        Effect   = "Allow",
        Sid      = ""
      }
    ]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name        = "S3BucketAccessPolicy"
  description = "Policy to allow S3 access for EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket", "s3:GetObject"],
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.s3_access_role.name
}

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "S3AccessInstanceProfile"
  role = aws_iam_role.s3_access_role.name
}

resource "aws_instance" "flask_server" {
  ami           = "ami-06b21ccaeff8cd686"
  instance_type = var.instance_type
  key_name      = var.key_pair

  iam_instance_profile = aws_iam_instance_profile.s3_access_profile.name
  security_groups      = [aws_security_group.allow_flask.name]

  provisioner "file" {
    source      = "app.py"
    destination = "/home/ec2-user/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras enable python3.9",
      "export BUCKET_NAME=${var.bucket_name}",
      "sudo yum install python3 pip -y",
      "sudo pip install flask boto3",
      "mkdir -p /home/ec2-user/app",
      "mv /home/ec2-user/app.py /home/ec2-user/app/",
      "cd /home/ec2-user/app",
      "nohup python3 app.py > app.log 2>&1 &"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("2023.pem")
    host        = self.public_ip
  }

  tags = { Name = "FlaskS3App" }
}
