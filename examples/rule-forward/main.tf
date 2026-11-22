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

  name              = "forward-corporate"
  domain_name       = "corp.example.com"
  outbound_endpoint = var.outbound_endpoint
  target_ips        = [for ip in var.dns_server_ips : { ipv4_address = ip }]

  tags = {
    "project" = "terraform-aws-route53-resolver-examples"
  }
}
