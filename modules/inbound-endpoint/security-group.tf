locals {
  ingress_dns_rules = concat(
    (contains(var.protocols, "Do53")
      ? [for protocol in ["tcp", "udp"] : {
        id       = "dns-${protocol}"
        protocol = protocol
        port     = 53
      }]
      : []
    ),
    (contains(var.protocols, "DoH") || contains(var.protocols, "DoH-FIPS")
      ? [{
        id       = "doh"
        protocol = "tcp"
        port     = 443
      }]
      : []
    ),
  )

  security_groups = concat(module.security_group[*].id, var.security_groups)
}

data "aws_subnet" "this" {
  for_each = toset(var.ip_allocations[*].subnet)

  region = var.region

  id = each.value
}


###################################################
# Security Group
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 1.3.0"

  count = var.default_security_group.enabled ? 1 : 0

  region = var.region

  name        = coalesce(var.default_security_group.name, local.metadata.name)
  description = var.default_security_group.description
  vpc_id      = values(data.aws_subnet.this)[0].vpc_id

  ingress_rules = concat(
    var.default_security_group.ingress_rules,
    [
      for rule in local.ingress_dns_rules : {
        id          = rule.id
        description = "Allow to query to Route53 Resolver Inbound Endpoint."
        protocol    = rule.protocol
        from_port   = rule.port
        to_port     = rule.port

        ipv4_cidrs      = var.default_security_group.ingress_ipv4_cidrs
        ipv6_cidrs      = var.default_security_group.ingress_ipv6_cidrs
        prefix_lists    = var.default_security_group.ingress_prefix_lists
        security_groups = var.default_security_group.ingress_security_groups
      }
      if anytrue([
        length(var.default_security_group.ingress_ipv4_cidrs) > 0,
        length(var.default_security_group.ingress_ipv6_cidrs) > 0,
        length(var.default_security_group.ingress_prefix_lists) > 0,
        length(var.default_security_group.ingress_security_groups) > 0,
      ])
    ]
  )
  egress_rules = concat(
    var.default_security_group.egress_rules,
  )

  revoke_rules_on_delete = true
  resource_group = {
    enabled = false
  }
  module_tags_enabled = false

  tags = merge(
    local.module_tags,
    var.tags,
  )

  telemetry = {
    enabled = false
  }
}
