# Simple ECS cluster example

This example creates an ECS cluster with optional settings and tags using the root module from `examples/simple/main.tf`.

The repository Makefile generates `provider.tf` when you run `make lint` or `make test` from the repository root. Sign in to AWS first.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.100 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ../../ | n/a |
| <a name="module_naming"></a> [naming](#module\_naming) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Class environment | `string` | `"dev"` | no |
| <a name="input_cloud_resource_type"></a> [cloud\_resource\_type](#input\_cloud\_resource\_type) | Cloud resource type | `string` | `"ecs"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family | `string` | `"demo"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service | `string` | `"ecs"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Settings for the ECS cluster | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for the ECS cluster | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN that identifies the cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Name of the cluster |
| <a name="output_ecs_cluster_tags_all"></a> [ecs\_cluster\_tags\_all](#output\_ecs\_cluster\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider |
<!-- END_TF_DOCS -->
