provider "aws" {
  region = "us-east-1"
}

###################################################
# Route53 Resolver Rule
###################################################

module "rule" {
  source = "../../modules/rule"
  # source  = "tedilabs/route53-resolver/aws//modules/rule"
  # version = "~> 0.1.0"

  name        = "system-aws-corporate"
  domain_name = "aws.corp.example.com"
  type        = "SYSTEM"

  tags = {
    "project" = "terraform-aws-route53-resolver-examples"
  }
}
