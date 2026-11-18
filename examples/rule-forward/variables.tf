variable "outbound_endpoint" {
  description = "The ID of an existing outbound Resolver endpoint in us-east-1 with access to the target DNS servers."
  type        = string
  nullable    = false
}

variable "dns_server_ips" {
  description = "The IPv4 addresses of DNS servers for corp.example.com, reachable on TCP/UDP 53 from the endpoint."
  type        = list(string)
  nullable    = false
}
