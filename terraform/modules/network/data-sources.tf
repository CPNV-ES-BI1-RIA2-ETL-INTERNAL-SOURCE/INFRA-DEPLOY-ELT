# Get route53 zone ID
data "aws_route53_zone" "zone" {
  name = var.route53_tld
}
