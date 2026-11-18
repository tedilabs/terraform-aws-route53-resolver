###################################################
# VPC Associations
###################################################

resource "aws_route53_resolver_rule_association" "this" {
  for_each = {
    for association in var.vpc_associations :
    association.name => association
  }

  region = var.region

  name             = each.key
  resolver_rule_id = aws_route53_resolver_rule.this.id
  vpc_id           = each.value.vpc
}
