provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "aws_s3_bucket" "s3_bucket_site" {
  bucket = "${var.project_name}-${local.account_id_last4}-${var.name}-lambda"
}


resource "aws_s3_bucket_website_configuration" "s3_bucket_website_configuration" {
  bucket = aws_s3_bucket.s3_bucket_site.id

  index_document {
    suffix = var.index_document
  }
  error_document {
    key = var.error_document
  }
}
# Depends on CloudFront - Move?
resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket_site.id
  policy = templatefile("${path.module}/templates/s3_bucket_policy.json.tpl",
    {
      s3_bucket_arn  = aws_s3_bucket.s3_bucket_site.arn
      cloudfront_oai = aws_cloudfront_origin_access_identity.cdn_oai.iam_arn
    })
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket_site.id
  acl    = "private"
}
resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket_site.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}