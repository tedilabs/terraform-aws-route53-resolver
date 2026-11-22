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
# Route53 Resolver Outbound Endpoint
###################################################

module "endpoint" {
  source = "../../modules/outbound-endpoint"
  # source  = "tedilabs/route53-resolver/aws//modules/outbound-endpoint"
  # version = "~> 0.1.0"

  name = "resolver-outbound-simple"

  ip_allocations = [
    for subnet in data.aws_subnet.default : {
      subnet = subnet.id
    }
  ]
  default_security_group = {
    egress_ipv4_cidrs = var.dns_server_cidrs
  }

  tags = {
    "project" = "terraform-aws-route53-resolver-examples"
  }
}
