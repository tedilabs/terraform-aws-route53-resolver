# query-logging-simple

Creates a CloudWatch Logs group with seven-day retention and associates Resolver query logging with the default VPC in `us-east-1`. Requires a default VPC with no existing query logging association. The caller needs permissions to configure CloudWatch Logs delivery and create the Resolver service-linked role when it does not exist. See [AWS logging destination permissions](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs-choosing-target-resource.html).

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
| <a name="module_query_logging"></a> [query\_logging](#module\_query\_logging) | ../../modules/query-logging | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.query_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_query_logging"></a> [query\_logging](#output\_query\_logging) | The Route53 Resolver query logging configuration. |
<!-- END_TF_DOCS -->
