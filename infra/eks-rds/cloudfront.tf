# CloudFront Distribution
resource "aws_cloudfront_distribution" "app_cdn" {
  origin {
    domain_name = "k8s-albdev-4c706dacac-2018138021.us-east-1.elb.amazonaws.com"
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for application"
  default_root_object = ""

  aliases = ["app-assess.chebsam.people.aws.dev"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:533267037417:certificate/483743fd-14bf-4650-b08b-36c637ab32b4"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [helm_release.aws_load_balancer_controller]
}

# Update Route53 Record
resource "aws_route53_record" "app_cdn" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "app-assess.chebsam.people.aws.dev"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.app_cdn.hosted_zone_id
    evaluate_target_health = true
  }
}

# Get Route53 Zone Data
data "aws_route53_zone" "selected" {
  name         = "chebsam.people.aws.dev."
  private_zone = false
}