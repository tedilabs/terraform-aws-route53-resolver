locals {
  security_groups = concat(
    module.security_group[*].id,
    var.security_groups,
  )
  dns_egress_ports = concat(
    contains(var.protocols, "Do53") ? [
      { id = "dns-tcp", protocol = "tcp", port = 53 },
      { id = "dns-udp", protocol = "udp", port = 53 },
    ] : [],
    contains(var.protocols, "DoH") ? [
      { id = "doh", protocol = "tcp", port = 443 },
    ] : [],
  )
}

data "aws_subnet" "this" {
  count = length(var.ip_allocations)

  region = var.region
  id     = var.ip_allocations[count.index].subnet
}


###################################################
# Security Group
###################################################

module "security_group" {
  source  = "tedilabs/network/aws//modules/security-group"
  version = "~> 1.5.0"

  count = var.default_security_group.enabled ? 1 : 0

  region = var.region

  name        = coalesce(var.default_security_group.name, local.metadata.name)
  description = var.default_security_group.description
  vpc_id      = data.aws_subnet.this[0].vpc_id

  ingress_rules = var.default_security_group.ingress_rules
  egress_rules = concat(
    var.default_security_group.egress_rules,
    [
      for rule in local.dns_egress_ports : {
        id          = rule.id
        description = "Allow DNS queries from Route53 Resolver Outbound Endpoint."
        protocol    = rule.protocol
        from_port   = rule.port
        to_port     = rule.port

        ipv4_cidrs      = var.default_security_group.egress_ipv4_cidrs
        ipv6_cidrs      = var.default_security_group.egress_ipv6_cidrs
        prefix_lists    = var.default_security_group.egress_prefix_lists
        security_groups = var.default_security_group.egress_security_groups
      }
      if anytrue([
        length(var.default_security_group.egress_ipv4_cidrs) > 0,
        length(var.default_security_group.egress_ipv6_cidrs) > 0,
        length(var.default_security_group.egress_prefix_lists) > 0,
        length(var.default_security_group.egress_security_groups) > 0,
      ])
    ],
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
