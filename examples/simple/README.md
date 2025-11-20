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
| <a name="module_ecs_service"></a> [ecs\_service](#module\_ecs\_service) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.subnet1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.subnet2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for the ECS service | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | Network configuration for the ECS service | <pre>object({<br/>    subnets          = list(string)<br/>    security_groups  = list(string)<br/>    assign_public_ip = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone for the subnet | `string` | `"us-east-2a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The IDs of the subnets |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_ecs_service_id"></a> [ecs\_service\_id](#output\_ecs\_service\_id) | The ID of the ECS service |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | The name of the ECS service |
| <a name="output_ecs_service_cluster"></a> [ecs\_service\_cluster](#output\_ecs\_service\_cluster) | The cluster the ECS service is associated with |
| <a name="output_ecs_service_desired_count"></a> [ecs\_service\_desired\_count](#output\_ecs\_service\_desired\_count) | The desired number of tasks for the ECS service |
| <a name="output_ecs_service_task_definition"></a> [ecs\_service\_task\_definition](#output\_ecs\_service\_task\_definition) | The task definition ARN used by the ECS service |
| <a name="output_ecs_service_launch_type"></a> [ecs\_service\_launch\_type](#output\_ecs\_service\_launch\_type) | The launch type of the ECS service |
<!-- END_TF_DOCS -->
