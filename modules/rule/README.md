# rule

This module creates following resources.

- `aws_route53_resolver_rule`
- `aws_ram_resource_share` (optional)
- `aws_ram_principal_association` (optional)
- `aws_ram_resource_association` (optional)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.16 |
| <a name="requirement_assert"></a> [assert](#requirement\_assert) | >= 0.15 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.12 |
| <a name="requirement_telemetry"></a> [telemetry](#requirement\_telemetry) | >= 0.2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.12 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.13.0 |
| <a name="module_share"></a> [share](#module\_share) | tedilabs/organization/aws//modules/ram-share | ~> 0.9.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_route53_resolver_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | (Required) The domain matched by the rule. Use `.` to match all domains or a reverse DNS zone such as `0.10.in-addr.arpa` for reverse lookups. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the Route53 Resolver rule. | `string` | n/a | yes |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module information. | `bool` | `true` | no |
| <a name="input_outbound_endpoint"></a> [outbound\_endpoint](#input\_outbound\_endpoint) | (Optional) The ID of an existing outbound Resolver endpoint. Required for `FORWARD`; must be omitted for `SYSTEM`. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configuration of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_shares"></a> [shares](#input\_shares) | (Optional) A list of resource shares via RAM (Resource Access Manager). Each block of `shares` as defined below.<br/>    (Required) `name` - The name of the resource share. The name of the RAM resource share is generated with the name of the resolver rule as a prefix.<br/>    (Optional) `permissions` - A set of the names of the RAM permissions to associate with the resource share. Defaults to `["AWSRAMDefaultPermissionResolverRule"]`.<br/>    (Optional) `external_principals_allowed` - Whether principals outside your organization can be associated with the resource share. Defaults to `false`.<br/>    (Optional) `principals` - A set of principals to associate with the resource share. Possible values are an AWS account ID, an ARN of an organization in AWS Organizations, an ARN of an organizational unit (OU) in AWS Organizations, or an ARN of an IAM role or user. Defaults to `[]`.<br/>    (Optional) `tags` - A map of tags to add to the resource share. Defaults to `{}`. | <pre>list(object({<br/>    name                        = string<br/>    permissions                 = optional(set(string), ["AWSRAMDefaultPermissionResolverRule"])<br/>    external_principals_allowed = optional(bool, false)<br/>    principals                  = optional(set(string), [])<br/>    tags                        = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_target_ips"></a> [target\_ips](#input\_target\_ips) | (Optional) Target DNS servers. At least one is required for `FORWARD`; must be empty for `SYSTEM`. All targets must use the same IP address family.<br/>    (Optional) `ipv4_address` - The target IPv4 address. Specify exactly one of `ipv4_address` and `ipv6_address`.<br/>    (Optional) `ipv6_address` - The target IPv6 address.<br/>    (Optional) `port` - An integer port from 1 to 65535. Defaults to 53 for Do53 and 443 for DoH.<br/>    (Optional) `protocol` - The target protocol, `Do53` or `DoH`. Defaults to `Do53`. The outbound endpoint must support this protocol. | <pre>list(object({<br/>    ipv4_address = optional(string)<br/>    ipv6_address = optional(string)<br/>    port         = optional(number)<br/>    protocol     = optional(string, "Do53")<br/>  }))</pre> | `[]` | no |
| <a name="input_telemetry"></a> [telemetry](#input\_telemetry) | (Optional) A configuration to collect telemetry data for the module. This is used to improve the module and its features. To send pseudonyms instead of identifying values such as the hostname and the Git remote, set `pseudonymization_enabled` to `true`. Pseudonyms are not anonymous; to keep data from being sent, disable its collector. The default configuration enables telemetry collection for machine, network, git, github, github actions, HCP Terraform, terraform, and toolchain. You can disable telemetry collection by setting `enabled` to `false`. `telemetry` block as defined below.<br/>    (Optional) `enabled` - Whether to enable telemetry collection. Default is `true`.<br/>    (Optional) `capture_machine` - Whether to capture machine information. Default is `true`.<br/>    (Optional) `capture_network` - Whether to capture network information. Default is `true`.<br/>    (Optional) `capture_git` - Whether to capture git information. Default is `true`.<br/>    (Optional) `capture_github` - Whether to capture GitHub information. Default is `true`.<br/>    (Optional) `capture_github_actions` - Whether to capture GitHub Actions information. Default is `true`.<br/>    (Optional) `capture_hcp_terraform` - Whether to capture HCP Terraform information. Default is `true`.<br/>    (Optional) `capture_terraform` - Whether to capture Terraform information. Default is `true`.<br/>    (Optional) `capture_toolchain` - Whether to capture toolchain information. Default is `true`.<br/>    (Optional) `pseudonymization_enabled` - Whether to enable pseudonymization of the captured data. Default is `false`. | <pre>object({<br/>    enabled = optional(bool, true)<br/><br/>    capture_machine        = optional(bool, true)<br/>    capture_network        = optional(bool, true)<br/>    capture_git            = optional(bool, true)<br/>    capture_github         = optional(bool, true)<br/>    capture_github_actions = optional(bool, true)<br/>    capture_hcp_terraform  = optional(bool, true)<br/>    capture_terraform      = optional(bool, true)<br/>    capture_toolchain      = optional(bool, true)<br/><br/>    pseudonymization_enabled = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | (Optional) How long to wait for the rule to be created, updated, or deleted. Each timeout defaults to `10m`. | <pre>object({<br/>    create = optional(string, "10m")<br/>    update = optional(string, "10m")<br/>    delete = optional(string, "10m")<br/>  })</pre> | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | (Optional) The rule type. `FORWARD` sends matching queries to target DNS servers. `SYSTEM` resolves a domain using Resolver's default behavior, overriding a broader forwarding rule. Defaults to `FORWARD`. | `string` | `"FORWARD"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the Route 53 Resolver rule. |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The domain matched by the rule. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Route 53 Resolver rule. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Route 53 Resolver rule. |
| <a name="output_outbound_endpoint"></a> [outbound\_endpoint](#output\_outbound\_endpoint) | The outbound endpoint used by a FORWARD rule. |
| <a name="output_owner_id"></a> [owner\_id](#output\_owner\_id) | The AWS account ID that owns the Resolver rule. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
| <a name="output_sharing"></a> [sharing](#output\_sharing) | The configuration for sharing of the Route53 Resolver rule.<br/>    `status` - An indication of whether the rule is shared with other AWS accounts, or was shared with the current account by another AWS account. Sharing is configured through AWS Resource Access Manager (AWS RAM). Values are `NOT_SHARED`, `SHARED_BY_ME` or `SHARED_WITH_ME`.<br/>    `shares` - The list of resource shares via RAM (Resource Access Manager). |
| <a name="output_target_ips"></a> [target\_ips](#output\_target\_ips) | The target DNS servers and their protocols and ports. |
| <a name="output_type"></a> [type](#output\_type) | The Resolver rule type. |
<!-- END_TF_DOCS -->
