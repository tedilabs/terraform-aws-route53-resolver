# inbound-endpoint-simple

Creates an inbound endpoint in two default subnets and allows DNS queries from the default VPC CIDR. Requires a default VPC and default subnets in `us-east-1a` and `us-east-1b`. For queries from a connected network, add its CIDR to `default_security_group.ingress_ipv4_cidrs`.

## Usage

```sh
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` to remove the resources when finished.

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
| <a name="module_endpoint"></a> [endpoint](#module\_endpoint) | ../../modules/inbound-endpoint | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_subnet.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The Route53 Resolver Inbound Endpoint. |
<!-- END_TF_DOCS -->
