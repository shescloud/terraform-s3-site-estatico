//Cria o bucket s3 com o site estático
resource "aws_s3_bucket" "s3-bucket" {
  bucket = "${var.name}"
 
  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
//Cria um bucket s3 para logs
resource "aws_s3_bucket" "log-bucket" {
  bucket = "${var.log_bucket}"
}


//Cria a OAI do Cloudfront
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "${var.oai_name}"
}

//Cria a distribuição no Cloudfront
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.s3-bucket.bucket_regional_domain_name}"
    origin_id   = "s3-${var.name}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }


  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "${var.project}-${var.environment}"
  default_root_object = "index.html"
  price_class         = "PriceClass_All"
  aliases             = ["${var.name}.${var.domain}"]

  logging_config {
    include_cookies = true
    bucket          = "${aws_s3_bucket.log-bucket.bucket_regional_domain_name}"
    prefix          = "${var.project}-${var.environment}-log"
  }



  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "s3-${var.name}"

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "${var.ssl_arn}"
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_code         = "404"
    response_code      = "200"
    response_page_path = "/index.html"
  }
}


//Cria a politica do bucket que dá permissão pra OAI
resource "aws_s3_bucket_policy" "oai_policy" {
  bucket = "${var.name}"
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"
            },
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.s3-bucket.arn}/*"
        }
    ]
}
EOF

}


//Cria o record no Route 53
resource "aws_route53_record" "route-53-record" {
  zone_id = "${var.route53_zone_id}"
  name    = "${var.name}.${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.cloudfront_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.cloudfront_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}
