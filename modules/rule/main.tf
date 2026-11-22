locals {
  metadata = {
    package = "terraform-aws-route53-resolver"
    version = trimspace(file("${path.module}/../../VERSION"))
    module  = basename(path.module)
    name    = var.name
  }
  module_tags = var.module_tags_enabled ? {
    "module.terraform.io/package"   = local.metadata.package
    "module.terraform.io/version"   = local.metadata.version
    "module.terraform.io/name"      = local.metadata.module
    "module.terraform.io/full-name" = "${local.metadata.package}/${local.metadata.module}"
    "module.terraform.io/instance"  = local.metadata.name
  } : {}
}


###################################################
# Route53 Resolver Rule
###################################################

resource "aws_route53_resolver_rule" "this" {
  region = var.region

  name                 = local.metadata.name
  domain_name          = var.domain_name
  rule_type            = var.type
  resolver_endpoint_id = var.outbound_endpoint

  dynamic "target_ip" {
    for_each = var.target_ips

    content {
      ip       = target_ip.value.ipv4_address
      ipv6     = target_ip.value.ipv6_address
      port     = coalesce(target_ip.value.port, target_ip.value.protocol == "DoH" ? 443 : 53)
      protocol = target_ip.value.protocol
    }
  }

  timeouts {
    create = var.timeouts.create
    update = var.timeouts.update
    delete = var.timeouts.delete
  }

  tags = merge(
    {
      "Name" = local.metadata.name
    },
    local.module_tags,
    var.tags,
  )
}
