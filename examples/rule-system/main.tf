provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
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
  rule_type   = "SYSTEM"

  vpc_associations = [{
    name = "default-vpc"
    vpc  = data.aws_vpc.default.id
  }]

  tags = {
    "project" = "terraform-aws-route53-resolver-examples"
  }
}
