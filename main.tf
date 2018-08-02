provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "b" {
  bucket  = "test-assets.relativepath.io"
  acl     = "private"

  tags {
    Name = "Test bucket with Terraform"
  }
}

locals {
  s3_origin_id = "rpS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.b.bucket_regional_domain_name}"
    origin_id = "${local.s3_origin_id}"
  }

  enabled               = true
  is_ipv6_enabled       = true
  default_root_object   = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type  = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
