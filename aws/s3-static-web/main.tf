provider "aws" {
  profile = "gmail"
  region  = "eu-central-1"
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = var.name
}

resource "aws_s3_object" "my_object" {
  for_each = fileset("./static/", "**/*.*")
  ## one * star only flat files, two **  stars files and folders.
  bucket = aws_s3_bucket.my_bucket.id
  key    = each.value
  source = "./static/${each.value}"
  # etag makes the file update when it changes; see https://stackoverflow.com/questions/56107258/terraform-upload-file-to-s3-on-every-apply
  ## etag   = "./static/${each.value}"
  etag = filemd5("./static/${each.value}")
  ## for errors with content-type; https://github.com/localstack/localstack/issues/5814
  content_type = lookup(local.content_type_map, regex("\\.(?P<extension>[A-Za-z0-9]+)$", each.value).extension, "application/octet-stream")

  ## etag = "${md5(file("./static/${each.value}"))}"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_website_configuration" "website_example" {
  bucket = aws_s3_bucket.my_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}


resource "aws_s3_bucket_policy" "bucket_policy_example" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = jsonencode({
    ## Version = "2012-10-17"
    ## Id      = "MYBUCKETPOLICY"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
        #        Condition = {
        #          IPAddress = {
        #            "aws:SourceIp" = "8.8.8.8/32"
        #          }
        #        }

      }
    ]


  })
}

###WEBSITE FILES###
locals {
  content_type_map = {
    html = "text/html",
    js   = "application/javascript",
    css  = "text/css",
    svg  = "image/svg+xml",
    jpg  = "image/jpeg",
    ico  = "image/x-icon",
    png  = "image/png",
    gif  = "image/gif",
    pdf  = "application/pdf"
  }
}

#data "aws_iam_policy_document" "allow_public_access_policy" {
#  statement {
#    sid = "PublicReadGetObject"
#    effect =  "Allow"
#    principals {
#      identifiers = ["*"]
#      type        = "*"
#    }
#
#
#    actions = [
#      "s3:GetObject"
#    ]
#
#    resources = [
#      "arn:aws:s3:::${aws_s3_bucket.bucket_example.arn}/*"
#    ]
#  }
#
#
#}




#provider "aws" {
#  profile = "default"
#  region  = "eu-central-1"
#}
#
#resource "aws_s3_bucket" "s3_bucket_site" {
#  bucket = "${var.project_name}-${local.account_id_last4}-${var.name}-lambda"
#}
#
#
#resource "aws_s3_bucket_website_configuration" "s3_bucket_website_configuration" {
#  bucket = aws_s3_bucket.s3_bucket_site.id
#
#  index_document {
#    suffix = var.index_document
#  }
#  error_document {
#    key = var.error_document
#  }
#}
## Depends on CloudFront - Move?
#resource "aws_s3_bucket_policy" "s3_bucket_policy" {
#  bucket = aws_s3_bucket.s3_bucket_site.id
#  policy = templatefile("${path.module}/templates/s3_bucket_policy.json.tpl",
#    {
#      s3_bucket_arn  = aws_s3_bucket.s3_bucket_site.arn
#      cloudfront_oai = aws_cloudfront_origin_access_identity.cdn_oai.iam_arn
#    })
#}
#
#resource "aws_s3_bucket_acl" "s3_bucket_acl" {
#  bucket = aws_s3_bucket.s3_bucket_site.id
#  acl    = "private"
#}
#resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_controls" {
#  bucket = aws_s3_bucket.s3_bucket_site.id
#  rule {
#    object_ownership = "BucketOwnerEnforced"
#  }
#}