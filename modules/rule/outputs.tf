output "region" {
  description = "The AWS region this module resources resides in."
  value       = aws_route53_resolver_rule.this.region
}

output "id" {
  description = "The ID of the Route 53 Resolver rule."
  value       = aws_route53_resolver_rule.this.id
}

output "arn" {
  description = "The ARN of the Route 53 Resolver rule."
  value       = aws_route53_resolver_rule.this.arn
}

output "owner_id" {
  description = "The AWS account ID that owns the Resolver rule."
  value       = aws_route53_resolver_rule.this.owner_id
}

output "name" {
  description = "The name of the Route 53 Resolver rule."
  value       = aws_route53_resolver_rule.this.name
}

output "vpc_associations" {
  description = "The VPC associations, keyed by association name."
  value = {
    for name, association in aws_route53_resolver_rule_association.this : name => {
      id   = association.id
      name = association.name
      vpc  = association.vpc_id
    }
  }
}

output "profile_associations" {
  description = "A list of Route53 Profile associations with the rule."
  value = [
    for assoc in aws_route53profiles_resource_association.this : {
      id       = assoc.id
      name     = assoc.name
      owner_id = assoc.owner_id
      status   = assoc.status
      profile = {
        id     = assoc.profile_id
        region = assoc.region
      }
      resource = {
        type       = assoc.resource_type
        arn        = assoc.resource_arn
        properties = assoc.resource_properties
      }
    }
  ]
}

output "domain_name" {
  description = "The domain matched by the rule."
  value       = aws_route53_resolver_rule.this.domain_name
}

output "rule_type" {
  description = "The Resolver rule type."
  value       = aws_route53_resolver_rule.this.rule_type
}

output "outbound_endpoint" {
  description = "The outbound endpoint used by a FORWARD rule."
  value       = aws_route53_resolver_rule.this.resolver_endpoint_id
}

output "target_ips" {
  description = "The target DNS servers and their protocols and ports."
  value = [
    for target in aws_route53_resolver_rule.this.target_ip : {
      ipv4_address = target.ip
      ipv6_address = target.ipv6
      port         = target.port
      protocol     = target.protocol
    }
  ]
}

output "resource_group" {
  description = "The resource group created to manage resources in this module."
  value = merge(
    {
      enabled = var.resource_group.enabled && var.module_tags_enabled
    },
    (var.resource_group.enabled && var.module_tags_enabled
      ? {
        arn  = module.resource_group[0].arn
        name = module.resource_group[0].name
      }
      : {}
    )
  )
}

output "sharing" {
  description = <<EOF
  The configuration for sharing of the Route53 Resolver rule.
    `status` - An indication of whether the rule is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.
    `shares` - The list of resource shares via RAM (Resource Access Manager).
  EOF
  value = {
    status = aws_route53_resolver_rule.this.share_status
    shares = module.share
  }
}
