mock_provider "aws" {}

override_data {
  target = data.aws_subnet.this["subnet-0123456789abcdef0"]
  values = {
    availability_zone_id = "use1-az1"
  }
}

override_data {
  target = data.aws_subnet.this["subnet-0123456789abcdef1"]
  values = {
    availability_zone_id = "use1-az2"
  }
}

variables {
  name   = "test-inbound-metrics"
  region = "us-east-1"
  ip_allocations = [
    { subnet = "subnet-0123456789abcdef0" },
    { subnet = "subnet-0123456789abcdef1" },
  ]
  default_security_group = { enabled = false }
  security_groups        = ["sg-0123456789abcdef0"]
  resource_group         = { enabled = false }
  telemetry              = { enabled = false }
}

run "disabled_by_default" {
  command = plan
  assert {
    condition     = aws_route53_resolver_endpoint.this.rni_enhanced_metrics_enabled == false
    error_message = "Enhanced RNI metrics must be explicitly disabled by default."
  }
}

run "enable_metrics" {
  command = apply
  variables {
    rni_enhanced_metrics_enabled = true
  }
  assert {
    condition     = aws_route53_resolver_endpoint.this.rni_enhanced_metrics_enabled
    error_message = "Enhanced RNI metrics must be enabled when requested."
  }
}

run "disable_metrics_after_enabling" {
  command = plan
  variables {
    rni_enhanced_metrics_enabled = false
  }
  assert {
    condition     = aws_route53_resolver_endpoint.this.rni_enhanced_metrics_enabled == false
    error_message = "Setting false must disable previously enabled RNI metrics."
  }
}

run "delegation_metrics" {
  command = plan
  variables {
    delegation_enabled           = true
    rni_enhanced_metrics_enabled = true
  }
  assert {
    condition = (
      aws_route53_resolver_endpoint.this.direction == "INBOUND_DELEGATION" &&
      aws_route53_resolver_endpoint.this.rni_enhanced_metrics_enabled
    )
    error_message = "Delegation endpoints must support enhanced RNI metrics."
  }
}
