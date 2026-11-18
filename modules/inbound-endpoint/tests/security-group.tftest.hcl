mock_provider "aws" {
  mock_data "aws_subnet" {
    defaults = {
      vpc_id = "vpc-0123456789abcdef0"
    }
  }
}

variables {
  name   = "test-inbound-protocols"
  region = "us-east-1"
  ip_allocations = [
    { subnet = "subnet-0123456789abcdef0" },
    { subnet = "subnet-0123456789abcdef1" },
  ]
  default_security_group = {
    ingress_ipv4_cidrs = ["10.20.0.0/16"]
  }
  resource_group = { enabled = false }
  telemetry      = { enabled = false }
}

run "do53_preserves_rule_ids" {
  command = plan
  assert {
    condition = (
      toset(keys(module.security_group[0].ingress_rules)) == toset(["dns-tcp/ipv4/0", "dns-udp/ipv4/0"]) &&
      toset([for rule in module.security_group[0].ingress_rules : rule.protocol]) == toset(["tcp", "udp"]) &&
      alltrue([for rule in module.security_group[0].ingress_rules : rule.from_port == 53 && rule.to_port == 53]) &&
      length(module.security_group[0].egress_rules) == 0
    )
    error_message = "Default Do53 ingress must preserve TCP/UDP 53 rules and their IDs."
  }
}

run "reject_empty_protocols" {
  command = plan
  variables {
    protocols = []
  }
  expect_failures = [var.protocols]
}

run "doh_ingress" {
  command = plan
  variables {
    protocols = ["DoH"]
  }
  assert {
    condition = (
      length(module.security_group[0].ingress_rules) == 1 &&
      alltrue([for rule in module.security_group[0].ingress_rules : rule.protocol == "tcp" && rule.from_port == 443 && rule.to_port == 443])
    )
    error_message = "DoH must allow only TCP 443 ingress."
  }
}

run "doh_fips_ingress" {
  command = plan
  variables {
    protocols = ["DoH-FIPS"]
    default_security_group = {
      ingress_ipv6_cidrs = ["2001:db8::/64"]
    }
  }
  assert {
    condition = (
      length(module.security_group[0].ingress_rules) == 1 &&
      alltrue([for rule in module.security_group[0].ingress_rules : rule.protocol == "tcp" && rule.from_port == 443 && rule.to_port == 443])
    )
    error_message = "DoH-FIPS must allow TCP 443 from IPv6 sources."
  }
}

run "do53_with_doh" {
  command = plan
  variables {
    protocols = ["Do53", "DoH"]
    default_security_group = {
      ingress_prefix_lists = ["pl-0123456789abcdef0"]
    }
  }
  assert {
    condition = (
      length(module.security_group[0].ingress_rules) == 3 &&
      module.security_group[0].ingress_rules["dns-tcp/prefix-list/0"].from_port == 53 &&
      module.security_group[0].ingress_rules["dns-udp/prefix-list/0"].from_port == 53 &&
      module.security_group[0].ingress_rules["doh/prefix-list/0"].from_port == 443
    )
    error_message = "Do53 with DoH must allow both DNS transports and HTTPS from prefix lists."
  }
}

run "do53_with_doh_fips" {
  command = plan
  variables {
    protocols = ["Do53", "DoH-FIPS"]
    default_security_group = {
      ingress_security_groups = ["sg-0123456789abcdef0"]
    }
  }
  assert {
    condition = (
      length(module.security_group[0].ingress_rules) == 3 &&
      module.security_group[0].ingress_rules["dns-tcp/security-group/0"].from_port == 53 &&
      module.security_group[0].ingress_rules["dns-udp/security-group/0"].from_port == 53 &&
      module.security_group[0].ingress_rules["doh/security-group/0"].from_port == 443
    )
    error_message = "Do53 with DoH-FIPS must allow DNS and HTTPS from security group sources."
  }
}

run "no_implicit_ingress" {
  command = plan
  variables {
    protocols              = ["Do53", "DoH"]
    default_security_group = {}
  }
  assert {
    condition     = length(module.security_group[0].ingress_rules) == 0
    error_message = "No automatic ingress may be opened without configured sources."
  }
}

run "preserve_custom_rules" {
  command = plan
  variables {
    protocols = ["DoH"]
    default_security_group = {
      ingress_ipv4_cidrs = ["10.20.0.0/16"]
      ingress_rules = [{
        id         = "custom-dns"
        protocol   = "tcp"
        from_port  = 5353
        to_port    = 5353
        ipv4_cidrs = ["10.30.0.0/16"]
      }]
      egress_rules = [{
        id         = "custom-egress"
        protocol   = "tcp"
        from_port  = 8443
        to_port    = 8443
        ipv4_cidrs = ["10.40.0.0/16"]
      }]
    }
  }
  assert {
    condition = (
      length(module.security_group[0].ingress_rules) == 2 &&
      module.security_group[0].ingress_rules["custom-dns/ipv4/0"].from_port == 5353 &&
      module.security_group[0].ingress_rules["doh/ipv4/0"].from_port == 443 &&
      length(module.security_group[0].egress_rules) == 1 &&
      module.security_group[0].egress_rules["custom-egress/ipv4/0"].from_port == 8443
    )
    error_message = "Custom ingress and egress must remain alongside protocol-specific ingress."
  }
}

run "external_security_group" {
  command = plan
  variables {
    protocols              = ["DoH"]
    default_security_group = { enabled = false }
    security_groups        = ["sg-0123456789abcdef0"]
  }
  assert {
    condition = (
      length(module.security_group) == 0 &&
      aws_route53_resolver_endpoint.this.security_group_ids == toset(["sg-0123456789abcdef0"])
    )
    error_message = "External security groups must work without creating automatic rules."
  }
}

run "delegation_do53" {
  command = plan
  variables {
    delegation_enabled = true
  }
  assert {
    condition = (
      aws_route53_resolver_endpoint.this.direction == "INBOUND_DELEGATION" &&
      length(module.security_group[0].ingress_rules) == 2
    )
    error_message = "Delegation endpoints must retain Do53 ingress."
  }
}

run "reject_doh_with_fips" {
  command = plan
  variables {
    protocols = ["DoH", "DoH-FIPS"]
  }
  expect_failures = [var.protocols]
}

run "reject_delegation_doh" {
  command = plan
  variables {
    delegation_enabled = true
    protocols          = ["Do53", "DoH"]
  }
  expect_failures = [var.protocols]
}
