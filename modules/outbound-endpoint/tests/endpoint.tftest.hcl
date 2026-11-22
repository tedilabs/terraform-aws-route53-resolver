mock_provider "aws" {
  mock_data "aws_subnet" {
    defaults = {
      vpc_id               = "vpc-0123456789abcdef0"
      availability_zone_id = "use1-az1"
    }
  }
}

variables {
  name   = "test-outbound"
  region = "us-east-1"
  ip_allocations = [
    { subnet = "subnet-0123456789abcdef0" },
    { subnet = "subnet-0123456789abcdef1" },
  ]
  default_security_group = {
    egress_ipv4_cidrs = ["10.20.0.53/32"]
  }
  resource_group = { enabled = false }
  telemetry      = { enabled = false }
}

run "do53_egress" {
  command = plan

  assert {
    condition = (
      aws_route53_resolver_endpoint.this.direction == "OUTBOUND" &&
      length(module.security_group[0].egress_rules) == 2 &&
      length(module.security_group[0].ingress_rules) == 0 &&
      toset([for rule in module.security_group[0].egress_rules : rule.protocol]) == toset(["tcp", "udp"]) &&
      alltrue([for rule in module.security_group[0].egress_rules : rule.from_port == 53 && rule.to_port == 53])
    )
    error_message = "Do53 must allow only TCP/UDP 53 egress to configured destinations."
  }
}

run "doh_egress" {
  command = plan
  variables {
    protocols = ["DoH"]
  }
  assert {
    condition = (
      length(module.security_group[0].egress_rules) == 1 &&
      alltrue([for rule in module.security_group[0].egress_rules : rule.protocol == "tcp" && rule.from_port == 443 && rule.to_port == 443])
    )
    error_message = "DoH must allow only TCP 443 egress."
  }
}

run "combined_protocols_and_metrics" {
  command = plan
  variables {
    protocols                          = ["Do53", "DoH"]
    rni_enhanced_metrics_enabled       = true
    target_name_server_metrics_enabled = true
  }
  assert {
    condition = (
      length(module.security_group[0].egress_rules) == 3 &&
      aws_route53_resolver_endpoint.this.rni_enhanced_metrics_enabled &&
      aws_route53_resolver_endpoint.this.target_name_server_metrics_enabled
    )
    error_message = "Both protocols and enhanced metrics must be configured."
  }
}

run "no_implicit_egress" {
  command = plan
  variables {
    default_security_group = {}
  }
  assert {
    condition     = length(module.security_group[0].egress_rules) == 0
    error_message = "No egress may be opened without an explicit destination."
  }
}

run "custom_port" {
  command = plan
  variables {
    default_security_group = {
      egress_rules = [{
        id         = "custom-dns"
        protocol   = "tcp"
        from_port  = 5353
        to_port    = 5353
        ipv4_cidrs = ["10.20.0.53/32"]
      }]
    }
  }
  assert {
    condition = (
      length(module.security_group[0].egress_rules) == 1 &&
      alltrue([for rule in module.security_group[0].egress_rules : rule.from_port == 5353])
    )
    error_message = "Custom DNS ports must be preserved."
  }
}

run "custom_ingress_rules" {
  command = plan
  variables {
    default_security_group = {
      ingress_rules = [{
        id         = "custom-ingress"
        protocol   = "tcp"
        from_port  = 8443
        to_port    = 8443
        ipv4_cidrs = ["10.30.0.0/16"]
      }]
    }
  }
  assert {
    condition = (
      length(module.security_group[0].ingress_rules) == 1 &&
      alltrue([for rule in module.security_group[0].ingress_rules : rule.from_port == 8443])
    )
    error_message = "Custom ingress rules must be passed to the default security group."
  }
}

run "external_security_group" {
  command = plan
  variables {
    default_security_group = { enabled = false }
    security_groups        = ["sg-0123456789abcdef0"]
  }
  assert {
    condition = (
      length(module.security_group) == 0 &&
      aws_route53_resolver_endpoint.this.security_group_ids == toset(["sg-0123456789abcdef0"])
    )
    error_message = "External security groups must work without creating a default group."
  }
}

run "reject_inbound_only_protocol" {
  command = plan
  variables {
    protocols = ["DoH-FIPS"]
  }
  expect_failures = [var.protocols]
}

run "reject_empty_protocols" {
  command = plan
  variables {
    protocols = []
  }
  expect_failures = [var.protocols]
}

run "reject_single_ip_allocation" {
  command = plan
  variables {
    ip_allocations = [{ subnet = "subnet-0123456789abcdef0" }]
  }
  expect_failures = [var.ip_allocations]
}

run "require_security_group" {
  command = plan
  variables {
    default_security_group = { enabled = false }
    security_groups        = []
  }
  expect_failures = [var.security_groups]
}
