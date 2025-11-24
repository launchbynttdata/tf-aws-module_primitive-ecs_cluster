# tf-aws-module_primitive-ecs_cluster

This module provides a primitive Terraform module for creating an Amazon ECS cluster with support for various configurations including container insights, execute command configuration, and service connect defaults.

## Features

- Configurable cluster settings (Container Insights)
- Execute command configuration with logging
- Managed storage configuration for Fargate ephemeral storage encryption
- Service Connect defaults
- Comprehensive tagging

## Usage

```hcl
module "ecs_cluster" {
  source = "path/to/module"

  name = "my-ecs-cluster"

  settings = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]

  tags = {
    Environment = "dev"
  }
}
```

## Resources Created

- 1 ECS Cluster

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the ECS cluster (up to 255 letters, numbers, hyphens, and underscores) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of resource tags | `map(string)` | `{}` | no |
| <a name="input_settings"></a> [settings](#input\_settings) | Configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | Execute command configuration for the cluster | <pre>object({<br/>    execute_command_configuration = optional(object({<br/>      kms_key_id = optional(string)<br/>      logging    = optional(string, "DEFAULT")<br/>      log_configuration = optional(object({<br/>        cloud_watch_encryption_enabled = optional(bool, false)<br/>        cloud_watch_log_group_name     = optional(string)<br/>        s3_bucket_name                 = optional(string)<br/>        s3_bucket_encryption_enabled   = optional(bool, false)<br/>        s3_key_prefix                  = optional(string)<br/>      }))<br/>    }))<br/>    managed_storage_configuration = optional(object({<br/>      fargate_ephemeral_storage_kms_key_id = optional(string)<br/>      kms_key_id                           = string<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_service_connect_defaults"></a> [service\_connect\_defaults](#input\_service\_connect\_defaults) | Default Service Connect namespace | <pre>object({<br/>    namespace = string<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN that identifies the cluster |
| <a name="output_name"></a> [name](#output\_name) | Name of the cluster |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider |
<!-- END_TF_DOCS -->
