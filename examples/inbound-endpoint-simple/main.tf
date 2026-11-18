provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  for_each = toset(["us-east-1a", "us-east-1b"])

  vpc_id            = data.aws_vpc.default.id
  availability_zone = each.key
  default_for_az    = true
}


###################################################
# Route53 Resolver Inbound Endpoint
###################################################

module "endpoint" {
  source = "../../modules/inbound-endpoint"
  # source  = "tedilabs/route53-resolver/aws//modules/inbound-endpoint"
  # version = "~> 0.1.0"

  name = "resolver-inbound-simple"

  ip_allocations = [
    for subnet in data.aws_subnet.default : {
      subnet = subnet.id
    }
  ]
  default_security_group = {
    ingress_ipv4_cidrs = [data.aws_vpc.default.cidr_block]
  }

  tags = {
    "project" = "terraform-aws-route53-resolver-examples"
  }
}
