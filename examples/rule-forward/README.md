# rule-forward

Creates a forwarding rule for `corp.example.com` in `us-east-1`. Provide an existing outbound endpoint ID and reachable target DNS server IPs. The endpoint must permit TCP/UDP 53 to those servers.

## Usage

```sh
terraform init
terraform plan -var='outbound_endpoint=rslvr-out-REPLACE_ME' -var='dns_server_ips=["10.20.0.53"]'
```

After reviewing the plan, run `terraform apply` with the same variables. Run `terraform destroy` with those variables when finished.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_rule"></a> [rule](#module\_rule) | ../../modules/rule | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dns_server_ips"></a> [dns\_server\_ips](#input\_dns\_server\_ips) | The IPv4 addresses of DNS servers for corp.example.com, reachable on TCP/UDP 53 from the endpoint. | `list(string)` | n/a | yes |
| <a name="input_outbound_endpoint"></a> [outbound\_endpoint](#input\_outbound\_endpoint) | The ID of an existing outbound Resolver endpoint in us-east-1 with access to the target DNS servers. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_rule"></a> [rule](#output\_rule) | The Route53 Resolver rule. |
<!-- END_TF_DOCS -->
