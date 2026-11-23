variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "(Required) The name of the Route 53 Resolver query logging configuration."
  type        = string
}

variable "destination" {
  description = "(Required) The ARN of the resource that you want Route 53 Resolver to send query logs. You can send query logs to an S3 bucket, a CloudWatch Logs log group, or a Kinesis Data Firehose delivery stream."
  type        = string
}

variable "vpc_associations" {
  description = "(Optional) A list of VPC IDs that you want this query logging configuration to log queries for."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "profile_associations" {
  description = <<EOF
  (Optional) A list of configurations to associate Route53 Profiles with the query logging configuration. Each block of `profile_associations` as defined below.
    (Required) `name` - The name of the resource association with the Route53 profile.
    (Required) `profile` - The ID of the Route53 profile to associate with.
  EOF
  type = list(object({
    name    = string
    profile = string
  }))
  default  = []
  nullable = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module information."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group" {
  description = <<EOF
  (Optional) A configuration of Resource Group for this module. `resource_group` as defined below.
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
  (Optional) A list of resource shares via RAM (Resource Access Manager). Each block of `shares` as defined below.
    (Required) `name` - The name of the resource share. The name of the RAM resource share is generated with the name of the query logging configuration as a prefix.
    (Optional) `permissions` - A set of the names of the RAM permissions to associate with the resource share. Defaults to `["AWSRAMDefaultPermissionResolverQueryLogConfig"]`.
    (Optional) `external_principals_allowed` - Whether principals outside your organization can be associated with the resource share. Defaults to `false`.
    (Optional) `principals` - A set of principals to associate with the resource share. Possible values are an AWS account ID, an ARN of an organization in AWS Organizations, an ARN of an organizational unit (OU) in AWS Organizations, or an ARN of an IAM role or user. Defaults to `[]`.
    (Optional) `tags` - A map of tags to add to the resource share. Defaults to `{}`.
  EOF
  type = list(object({
    name = string

    permissions = optional(set(string), ["AWSRAMDefaultPermissionResolverQueryLogConfig"])

    external_principals_allowed = optional(bool, false)
    principals                  = optional(set(string), [])

    tags = optional(map(string), {})
  }))
  default  = []
  nullable = false
}
