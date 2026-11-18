provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_cloudwatch_log_group" "query_logging" {
  name              = "/aws/route53/resolver-query-logging-simple"
  retention_in_days = 7

  tags = {
    "project" = "terraform-aws-route53-resolver-examples"
  }
}


###################################################
# Route53 Resolver Query Logging
###################################################

module "query_logging" {
  source = "../../modules/resolver-query-logging"
  # source  = "tedilabs/route53-resolver/aws//modules/resolver-query-logging"
  # version = "~> 0.1.0"

  name             = "resolver-query-logging-simple"
  destination      = aws_cloudwatch_log_group.query_logging.arn
  vpc_associations = [data.aws_vpc.default.id]

  tags = {
    "project" = "terraform-aws-route53-resolver-examples"
  }
}
