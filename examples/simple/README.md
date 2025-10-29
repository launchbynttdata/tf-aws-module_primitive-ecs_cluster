# Simple Example

This example provides a basic test case for the `tf-aws-module_primitive-vpc_security_group_ingress_rule` module, used primarily for integration testing.

## Features

- Single SSH ingress rule (port 22)
- IPv4 CIDR source
- Basic configuration

## Usage

```bash
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
terraform destroy -var-file=test.tfvars
```

## Resources Created

- 1 VPC
- 1 Security Group
- 1 Security Group Ingress Rule

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ingress_ssh"></a> [ingress\_ssh](#module\_ingress\_ssh) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_security_group.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_name_prefix"></a> [resource\_name\_prefix](#input\_resource\_name\_prefix) | Prefix for resource names | `string` | `"sgir-simple"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| <a name="input_cidr_ipv4"></a> [cidr\_ipv4](#input\_cidr\_ipv4) | IPv4 CIDR block allowed for ingress | `string` | `"10.0.1.0/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the test security group |
| <a name="output_ingress_rule_id"></a> [ingress\_rule\_id](#output\_ingress\_rule\_id) | ID of the SSH ingress rule |
| <a name="output_ingress_rule_arn"></a> [ingress\_rule\_arn](#output\_ingress\_rule\_arn) | ARN of the SSH ingress rule |
| <a name="output_effective_source"></a> [effective\_source](#output\_effective\_source) | Effective source for SSH ingress rule |
<!-- END_TF_DOCS -->
