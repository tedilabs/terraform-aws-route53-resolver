# outbound-endpoint-simple

Creates an outbound endpoint in the default VPC's `us-east-1a` and `us-east-1b` subnets. Provide the IPv4 CIDRs of DNS servers reachable from that VPC. This example permits TCP/UDP 53 to those CIDRs; it does not create DNS servers, routes, or forwarding rules.

## Usage

```sh
terraform init
terraform plan -var='dns_server_cidrs=["10.20.0.53/32"]'
terraform apply -var='dns_server_cidrs=["10.20.0.53/32"]'
```

Replace the example CIDR with your DNS server address. Run `terraform destroy` with the same variables when finished.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.16 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_endpoint"></a> [endpoint](#module\_endpoint) | ../../modules/outbound-endpoint | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_subnet.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dns_server_cidrs"></a> [dns\_server\_cidrs](#input\_dns\_server\_cidrs) | IPv4 CIDRs of reachable target DNS servers, for example ["10.20.0.53/32"]. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The Route53 Resolver Outbound Endpoint. |
<!-- END_TF_DOCS -->
