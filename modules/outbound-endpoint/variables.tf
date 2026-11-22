variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the Route53 Resolver Outbound Endpoint."
  type        = string
  nullable    = false
}

variable "protocols" {
  description = "(Optional) A set of protocols for the outbound endpoint. Valid values are `Do53` and `DoH`. Defaults to `[\"Do53\"]`. DoH-FIPS is supported only by inbound endpoints."
  type        = set(string)
  default     = ["Do53"]
  nullable    = false

  validation {
    condition     = length(var.protocols) > 0
    error_message = "Specify at least one protocol for `protocols`."
  }
  validation {
    condition = alltrue([
      for protocol in var.protocols :
      contains(["Do53", "DoH"], protocol)
    ])
    error_message = "Valid values for `protocols` are `Do53` and `DoH`."
  }
}

variable "default_security_group" {
  description = <<EOF
  (Optional) The default security group for the outbound endpoint. DNS egress is allowed only to the configured destinations, using TCP/UDP 53 for Do53 and TCP 443 for DoH. Custom ports can be allowed with `egress_rules`.
    (Optional) `enabled` - Whether to create the default security group. Defaults to `true`.
    (Optional) `name` - The security group name. Defaults to the endpoint name.
    (Optional) `description` - The security group description. Defaults to `Managed by Terraform.`.
    (Optional) `egress_ipv4_cidrs` - IPv4 CIDRs of target DNS servers. Defaults to `[]`.
    (Optional) `egress_ipv6_cidrs` - IPv6 CIDRs of target DNS servers. Defaults to `[]`.
    (Optional) `egress_prefix_lists` - Destination prefix list IDs. Defaults to `[]`.
    (Optional) `egress_security_groups` - Destination security group IDs. Defaults to `[]`.
    (Optional) `egress_rules` - Additional egress rules. Defaults to `[]`.
      (Required) `id` - A unique internal identifier for the rule.
      (Optional) `description` - The rule description. Defaults to `Managed by Terraform.`.
      (Required) `protocol` - The IP protocol, or `-1` for all protocols.
      (Optional) `from_port` - The start of the port range. Required except for protocol `-1`.
      (Optional) `to_port` - The end of the port range. Required except for protocol `-1`.
      (Optional) `ipv4_cidrs` - Destination IPv4 CIDRs. Defaults to `[]`.
      (Optional) `ipv6_cidrs` - Destination IPv6 CIDRs. Defaults to `[]`.
      (Optional) `prefix_lists` - Destination prefix list IDs. Defaults to `[]`.
      (Optional) `security_groups` - Destination security group IDs. Defaults to `[]`.
      (Optional) `self` - Whether to allow the security group itself. Defaults to `false`.
  EOF
  type = object({
    enabled                = optional(bool, true)
    name                   = optional(string)
    description            = optional(string, "Managed by Terraform.")
    egress_ipv4_cidrs      = optional(list(string), [])
    egress_ipv6_cidrs      = optional(list(string), [])
    egress_prefix_lists    = optional(list(string), [])
    egress_security_groups = optional(list(string), [])
    egress_rules = optional(list(object({
      id              = string
      description     = optional(string, "Managed by Terraform.")
      protocol        = string
      from_port       = optional(number)
      to_port         = optional(number)
      ipv4_cidrs      = optional(list(string), [])
      ipv6_cidrs      = optional(list(string), [])
      prefix_lists    = optional(list(string), [])
      security_groups = optional(list(string), [])
      self            = optional(bool, false)
    })), [])
  })
  default  = {}
  nullable = false
}

variable "security_groups" {
  description = "(Optional) A list of security group IDs to assign to the Route53 Resolver Outbound Endpoint."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition     = var.default_security_group.enabled || length(var.security_groups) > 0
    error_message = "Provide `security_groups` when the default security group is disabled."
  }
}

variable "ip_address_type" {
  description = "(Optional) The type of IP addresses used by the Route53 Resolver Outbound Endpoint. Valid values are `IPV4`, `IPV6`, `DUALSTACK`. Defaults to `IPV4`."
  type        = string
  default     = "IPV4"
  nullable    = false

  validation {
    condition     = contains(["IPV4", "IPV6", "DUALSTACK"], var.ip_address_type)
    error_message = "Valid values for `ip_address_type` are `IPV4`, `IPV6` and `DUALSTACK`."
  }
}

variable "ip_allocations" {
  description = <<EOF
  (Required) The configuration for IP allocations of the Route53 Resolver Outbound Endpoint. Provide at least two IP allocations, preferably in different Availability Zones. Each item of `ip_allocations` block as defined below.
    (Required) `subnet` - The ID of the subnet that contains the IP address.
    (Optional) `ipv4_address` - IPv4 address from the provided subnet. Defaults to be randomly configured by Amazon.
    (Optional) `ipv6_address` - IPv6 address from the provided subnet. Defaults to be randomly configured by Amazon.
  EOF
  type = list(object({
    subnet       = string
    ipv4_address = optional(string)
    ipv6_address = optional(string)
  }))
  nullable = false

  validation {
    condition     = length(var.ip_allocations) >= 2
    error_message = "To improve reliability, Resolver requires that you specify two IP addresses for DNS queries. We recommend that you specify IP addresses in two different Availability Zones. After you add the first two IP addresses, you can optionally add more in the same or different Availability Zones."
  }
  validation {
    condition = alltrue([
      for ip_allocation in var.ip_allocations :
      (ip_allocation.ipv4_address != null
        ? provider::assert::ipv4(ip_allocation.ipv4_address)
        : true
      )
    ])
    error_message = "Value of `ipv4_address` is not valid IPv4 address."
  }
  validation {
    condition = alltrue([
      for ip_allocation in var.ip_allocations :
      (ip_allocation.ipv6_address != null
        ? provider::assert::ipv6(ip_allocation.ipv6_address)
        : true
      )
    ])
    error_message = "Value of `ipv6_address` is not valid IPv6 address."
  }
}

variable "rni_enhanced_metrics_enabled" {
  description = "(Optional) Whether to enable Resolver network interface enhanced metrics. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "target_name_server_metrics_enabled" {
  description = "(Optional) Whether to enable target name server metrics for the outbound endpoint. Defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "timeouts" {
  description = "(Optional) How long to wait for the endpoint to be created, updated, or deleted. Each timeout defaults to `10m`."
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
