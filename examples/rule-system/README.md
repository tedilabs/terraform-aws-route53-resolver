# rule-system

Creates a SYSTEM rule for `aws.corp.example.com` in `us-east-1`. When a broader `corp.example.com` forwarding rule exists, this subdomain uses Resolver's default resolution instead. No outbound endpoint is required.

## Usage

```sh
terraform init
terraform plan
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

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_rule"></a> [rule](#output\_rule) | The Route53 Resolver rule. |
<!-- END_TF_DOCS -->
