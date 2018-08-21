provider "aws" {
  region = "us-west-2"
}

locals {
  web_bucket  = "com.cookesauction"
}

locals {
  cdn_bucket        = "${local.web_bucket}.cdn"
  web_origin_id     = "${local.web_bucket}.WebOrigin"
  cdn_origin_id     = "${local.web_bucket}.CDNOrigin"
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "To access S3 bucket data"
}

resource "aws_s3_bucket" "cookesauction_com" {
  bucket  = "${local.web_bucket}"
  acl     = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["HEAD", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  tags {
    Name = "Managed with Terraform"
  }
}

resource "aws_s3_bucket" "cdn_cookesauction_com" {
  bucket  = "${local.cdn_bucket}"
  acl     = "public-read"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["HEAD", "GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  tags {
    Name = "Managed with Terraform"
  }
}

resource "aws_cloudfront_distribution" "cookesauction_com_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.cookesauction_com.bucket_regional_domain_name}"
    origin_id = "${local.web_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path}"
    }
  }

  enabled               = true
  is_ipv6_enabled       = true
  default_root_object   = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.web_origin_id}"

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

resource "aws_cloudfront_distribution" "cdn_cookesauction_com_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.cdn_cookesauction_com.bucket_regional_domain_name}"
    origin_id = "${local.cdn_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path}"
    }
  }

  enabled               = true
  is_ipv6_enabled       = true
  default_root_object   = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.cdn_origin_id}"

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

data "aws_iam_policy_document" "cookesauction_com_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cookesauction_com.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.default.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.cookesauction_com.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.default.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "cookesauction_com_bucket_policy" {
  bucket = "${aws_s3_bucket.cookesauction_com.id}"
  policy = "${data.aws_iam_policy_document.cookesauction_com_s3_policy.json}"
}

data "aws_iam_policy_document" "cdn_cookesauction_com_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cdn_cookesauction_com.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.default.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.cdn_cookesauction_com.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.default.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn_cookesauction_com_bucket_policy" {
  bucket = "${aws_s3_bucket.cdn_cookesauction_com.id}"
  policy = "${data.aws_iam_policy_document.cdn_cookesauction_com_s3_policy.json}"
}
