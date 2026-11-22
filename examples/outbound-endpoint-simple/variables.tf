variable "dns_server_cidrs" {
  description = "IPv4 CIDRs of reachable target DNS servers, for example [\"10.20.0.53/32\"]."
  type        = list(string)
  nullable    = false

  validation {
    condition     = length(var.dns_server_cidrs) > 0
    error_message = "Provide at least one target DNS server CIDR."
  }
}
