provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "static_website" {
  bucket = "my-static-website-bucket-fsl-leonardo-${var.environment}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  versioning {
    enabled = true
  }

  tags = {
    Name        = "Leonardo FSL Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "static_website" {
  depends_on = [aws_s3_bucket_ownership_controls.static_website, aws_s3_bucket_public_access_block.static_website]

  bucket = aws_s3_bucket.static_website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "static_website" {
  bucket = aws_s3_bucket.static_website.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect    = "Allow"
          Principal = "*"
          Action    = "s3:GetObject"
          Resource  = "${aws_s3_bucket.static_website.arn}/*"
        }
      ]
    }
  )
}


output "website_endpoint" {
  description = "The Website Endpoint"
  value       = aws_s3_bucket.static_website.website_endpoint
}

variable "environment" {
  type        = string
  default     = ""
  description = "The name of the environment"
}

#Development (devel)
#Staging (stage)
#Production (prod)