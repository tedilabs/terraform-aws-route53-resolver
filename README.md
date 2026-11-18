# terraform-aws-route53-resolver

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-route53-resolver?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-route53-resolver?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform modules which create Route53 Resolver related resources on AWS.

- [resolver-inbound-endpoint](./modules/resolver-inbound-endpoint)
- [resolver-query-logging](./modules/resolver-query-logging)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-route53-resolver) were written to manage the following AWS Services with Terraform.

- **Route53 Resolver**
  - Inbound Endpoint
  - Query Logging Configuration
    - VPC and Route53 Profile Associations
    - Resource Sharing via AWS RAM


## Examples

- [resolver-inbound-endpoint-simple](./examples/resolver-inbound-endpoint-simple)
- [resolver-query-logging-simple](./examples/resolver-query-logging-simple)


## Migration from terraform-aws-domain

These modules were moved from [terraform-aws-domain](https://github.com/tedilabs/terraform-aws-domain). Change `tedilabs/domain/aws//modules/<module-name>` to `tedilabs/route53-resolver/aws//modules/<module-name>` and select a published version of this package. Module names, inputs, outputs, and internal resource addresses are unchanged.

Keep the existing module block names to preserve Terraform state addresses. Package/version tags and the generated resource group name change with this package. Set `resource_group.name` to the existing name if you want to preserve it, then run `terraform init` and review `terraform plan` before applying.


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-route53-resolver). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2021-2026, [Byungjin Park](https://www.posquit0.com).
