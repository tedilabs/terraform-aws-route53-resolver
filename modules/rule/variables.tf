variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the Route53 Resolver rule."
  type        = string
  nullable    = false
}

variable "domain_name" {
  description = "(Required) The domain matched by the rule. Use `.` to match all domains or a reverse DNS zone such as `0.10.in-addr.arpa` for reverse lookups."
  type        = string
  nullable    = false
}

variable "type" {
  description = "(Optional) The rule type. `FORWARD` sends matching queries to target DNS servers. `SYSTEM` resolves a domain using Resolver's default behavior, overriding a broader forwarding rule. Defaults to `FORWARD`."
  type        = string
  default     = "FORWARD"
  nullable    = false

  validation {
    condition     = contains(["FORWARD", "SYSTEM"], var.type)
    error_message = "Valid values for `type` are `FORWARD` and `SYSTEM`."
  }
}

variable "outbound_endpoint" {
  description = "(Optional) The ID of an existing outbound Resolver endpoint. Required for `FORWARD`; must be omitted for `SYSTEM`."
  type        = string
  default     = null

  validation {
    condition = (var.type == "FORWARD"
      ? try(trimspace(var.outbound_endpoint) != "", false)
      : var.outbound_endpoint == null
    )
    error_message = "Provide `outbound_endpoint` for FORWARD rules and omit it for SYSTEM rules."
  }
}

variable "target_ips" {
  description = <<EOF
  (Optional) Target DNS servers. At least one is required for `FORWARD`; must be empty for `SYSTEM`. All targets must use the same IP address family.
    (Optional) `ipv4_address` - The target IPv4 address. Specify exactly one of `ipv4_address` and `ipv6_address`.
    (Optional) `ipv6_address` - The target IPv6 address.
    (Optional) `port` - An integer port from 1 to 65535. Defaults to 53 for Do53 and 443 for DoH.
    (Optional) `protocol` - The target protocol, `Do53` or `DoH`. Defaults to `Do53`. The outbound endpoint must support this protocol.
  EOF
  type = list(object({
    ipv4_address = optional(string)
    ipv6_address = optional(string)
    port         = optional(number)
    protocol     = optional(string, "Do53")
  }))
  default  = []
  nullable = false

  validation {
    condition     = var.type == "FORWARD" ? length(var.target_ips) > 0 : length(var.target_ips) == 0
    error_message = "Provide at least one target for FORWARD rules and no targets for SYSTEM rules."
  }
  validation {
    condition = alltrue([
      for target in var.target_ips :
      (target.ipv4_address != null) != (target.ipv6_address != null)
    ])
    error_message = "Each target must specify exactly one IPv4 or IPv6 address."
  }
  validation {
    condition = alltrue([
      for target in var.target_ips :
      target.ipv4_address == null ? true : provider::assert::ipv4(target.ipv4_address)
    ])
    error_message = "Each `ipv4_address` must be a valid IPv4 address."
  }
  validation {
    condition = alltrue([
      for target in var.target_ips :
      target.ipv6_address == null ? true : provider::assert::ipv6(target.ipv6_address)
    ])
    error_message = "Each `ipv6_address` must be a valid IPv6 address."
  }
  validation {
    condition = (alltrue([for target in var.target_ips : target.ipv4_address != null]) ||
      alltrue([for target in var.target_ips : target.ipv6_address != null])
    )
    error_message = "All targets in a rule must use the same IP address family."
  }
  validation {
    condition = alltrue([
      for target in var.target_ips :
      target.port == null ? true : target.port >= 1 && target.port <= 65535 && floor(target.port) == target.port
    ])
    error_message = "Target ports must be integers between 1 and 65535."
  }
  validation {
    condition     = alltrue([for target in var.target_ips : contains(["Do53", "DoH"], target.protocol)])
    error_message = "Valid target protocols are `Do53` and `DoH`."
  }
}

variable "timeouts" {
  description = "(Optional) How long to wait for the rule to be created, updated, or deleted. Each timeout defaults to `10m`."
  type = object({
    create = optional(string, "10m")
    update = optional(string, "10m")
    delete = optional(string, "10m")
  })
  default  = {}
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}


###################################################
# Resource Sharing by RAM (Resource Access Manager)
###################################################

variable "shares" {
  description = <<EOF
  (Optional) Resource shares via AWS RAM. Defaults to `[]`.
    (Required) `name` - A unique share name, used as the Terraform instance key. Must be known at plan time.
    (Optional) `permissions` - RAM permission names or ARNs. Defaults to `[]`, which uses the AWS default permission for the resource type.
    (Optional) `external_principals_allowed` - Whether to allow principals outside the organization. Defaults to `false`.
    (Optional) `principals` - Account IDs, organization ARNs, or organizational unit ARNs to share with. Defaults to `[]`.
    (Optional) `tags` - Additional tags for the share. Defaults to `{}`.
  EOF
  type = list(object({
    name                        = string
    permissions                 = optional(set(string), [])
    external_principals_allowed = optional(bool, false)
    principals                  = optional(set(string), [])
    tags                        = optional(map(string), {})
  }))
  default  = []
  nullable = false

  validation {
    condition     = length(distinct(var.shares[*].name)) == length(var.shares)
    error_message = "Share names must be unique."
  }
}
