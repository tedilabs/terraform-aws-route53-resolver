mock_provider "aws" {
  mock_resource "aws_ram_resource_share" {
    defaults = {
      arn = "arn:aws:ram:us-east-1:123456789012:resource-share/12345678-1234-1234-1234-123456789012"
    }
  }

  mock_resource "aws_route53_resolver_rule" {
    defaults = {
      id  = "rslvr-rr-0123456789abcdef0"
      arn = "arn:aws:route53resolver:us-east-1:123456789012:resolver-rule/rslvr-rr-0123456789abcdef0"
    }
  }
}

variables {
  name              = "test-rule"
  region            = "us-east-1"
  domain_name       = "corp.example.com"
  outbound_endpoint = "rslvr-out-0123456789abcdef0"
  target_ips        = [{ ipv4_address = "10.20.0.53" }]
  resource_group    = { enabled = false }
  telemetry         = { enabled = false }
}

run "forward_defaults" {
  command = plan
  assert {
    condition = (
      aws_route53_resolver_rule.this.rule_type == "FORWARD" &&
      aws_route53_resolver_rule.this.resolver_endpoint_id == var.outbound_endpoint &&
      one(aws_route53_resolver_rule.this.target_ip).ip == "10.20.0.53" &&
      one(aws_route53_resolver_rule.this.target_ip).port == 53 &&
      one(aws_route53_resolver_rule.this.target_ip).protocol == "Do53"
    )
    error_message = "A forwarding rule must point to the selected endpoint and DNS server."
  }
}

run "ipv6_doh_default_port" {
  command = plan
  variables {
    target_ips = [{ ipv6_address = "2001:db8::53", protocol = "DoH" }]
  }
  assert {
    condition = (
      one(aws_route53_resolver_rule.this.target_ip).ipv6 == "2001:db8::53" &&
      one(aws_route53_resolver_rule.this.target_ip).port == 443 &&
      one(aws_route53_resolver_rule.this.target_ip).protocol == "DoH"
    )
    error_message = "DoH must default to port 443 and preserve IPv6 addresses."
  }
}

run "explicit_port" {
  command = plan
  variables {
    target_ips = [{ ipv4_address = "10.20.0.53", protocol = "DoH", port = 8443 }]
  }
  assert {
    condition     = one(aws_route53_resolver_rule.this.target_ip).port == 8443
    error_message = "Explicit ports must take precedence over protocol defaults."
  }
}

run "system_rule" {
  command = plan
  variables {
    type              = "SYSTEM"
    outbound_endpoint = null
    target_ips        = []
  }
  assert {
    condition = (
      aws_route53_resolver_rule.this.rule_type == "SYSTEM" &&
      aws_route53_resolver_rule.this.resolver_endpoint_id == null &&
      length(aws_route53_resolver_rule.this.target_ip) == 0
    )
    error_message = "SYSTEM rules must not use outbound endpoints or target IPs."
  }
}

run "sharing" {
  command = apply
  variables {
    shares = [{ name = "workloads", principals = ["123456789013"] }]
  }
  assert {
    condition = (
      length(output.sharing.shares) == 1 &&
      contains(output.sharing.shares["workloads"].resources, output.arn) &&
      contains(output.sharing.shares["workloads"].principals, "123456789013")
    )
    error_message = "RAM shares must reference the created rule."
  }
  assert {
    condition     = contains(output.sharing.shares["workloads"].permissions, "arn:aws:ram::aws:permission/AWSRAMDefaultPermissionResolverRule")
    error_message = "RAM shares must use the default RAM permission for resolver rules."
  }
}

run "reject_forward_without_endpoint" {
  command = plan
  variables {
    outbound_endpoint = null
  }
  expect_failures = [var.outbound_endpoint]
}

run "reject_forward_without_targets" {
  command = plan
  variables {
    target_ips = []
  }
  expect_failures = [var.target_ips]
}

run "reject_system_with_forwarding" {
  command = plan
  variables {
    type = "SYSTEM"
  }
  expect_failures = [var.outbound_endpoint, var.target_ips]
}

run "reject_dual_address_target" {
  command = plan
  variables {
    target_ips = [{ ipv4_address = "10.20.0.53", ipv6_address = "2001:db8::53" }]
  }
  expect_failures = [var.target_ips]
}

run "reject_mixed_address_families" {
  command = plan
  variables {
    target_ips = [{ ipv4_address = "10.20.0.53" }, { ipv6_address = "2001:db8::53" }]
  }
  expect_failures = [var.target_ips]
}

run "reject_invalid_ipv4" {
  command = plan
  variables {
    target_ips = [{ ipv4_address = "999.20.0.53" }]
  }
  expect_failures = [var.target_ips]
}

run "reject_fractional_port" {
  command = plan
  variables {
    target_ips = [{ ipv4_address = "10.20.0.53", port = 53.5 }]
  }
  expect_failures = [var.target_ips]
}

run "reject_unsupported_protocol" {
  command = plan
  variables {
    target_ips = [{ ipv4_address = "10.20.0.53", protocol = "DoH-FIPS" }]
  }
  expect_failures = [var.target_ips]
}

run "reject_recursive_rule" {
  command = plan
  variables {
    type              = "RECURSIVE"
    outbound_endpoint = null
    target_ips        = []
  }
  expect_failures = [var.type]
}
