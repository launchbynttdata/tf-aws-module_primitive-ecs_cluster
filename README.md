# tf-aws-module_primitive-ecs_service

This module provides a primitive Terraform module for creating an Amazon ECS service with support for various configurations including load balancers, service discovery, and more.

## Features

- Supports Fargate and EC2 launch types
- Configurable network settings with subnets and security groups
- Load balancer integration
- Service Connect for service-to-service communication
- Service discovery registries
- Capacity provider strategies
- Deployment configurations with circuit breakers and alarms
- Volume configurations for EBS attachments
- ECS Exec support
- Comprehensive tagging and managed tags

## Usage

```hcl
module "ecs_service" {
  source = "path/to/module"

  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.example.arn
  task_definition = aws_ecs_task_definition.example.arn

  desired_count = 2
  launch_type   = "FARGATE"

  network_configuration = {
    subnets          = [aws_subnet.example.id]
    security_groups  = [aws_security_group.example.id]
    assign_public_ip = false
  }

  tags = {
    Environment = "dev"
  }
}
```

## Resources Created

- 1 ECS Service
- 1 Service Discovery Service (data source, if Service Connect lookup is configured)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_service_discovery_service.service_connect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/service_discovery_service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name for the ECS service | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to the ECS service | `map(string)` | `{}` | no |
| <a name="input_cluster"></a> [cluster](#input\_cluster) | ARN of the ECS cluster where this service will be placed | `string` | n/a | yes |
| <a name="input_task_definition"></a> [task\_definition](#input\_task\_definition) | The family and revision (family:revision) or full ARN of the task definition to run in your service | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| <a name="input_launch_type"></a> [launch\_type](#input\_launch\_type) | The launch type on which to run your service. Valid values: EC2, FARGATE, EXTERNAL | `string` | `"FARGATE"` | no |
| <a name="input_platform_version"></a> [platform\_version](#input\_platform\_version) | The platform version on which to run your service. Only applicable for launch\_type set to FARGATE | `string` | `"LATEST"` | no |
| <a name="input_iam_role"></a> [iam\_role](#input\_iam\_role) | The ARN of an IAM role that allows your Amazon ECS service to make calls to other AWS services | `string` | `null` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Whether to enable Amazon ECS Exec for the tasks in the service | `bool` | `false` | no |
| <a name="input_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#input\_enable\_ecs\_managed\_tags) | Whether to enable Amazon ECS managed tags for the tasks in the service | `bool` | `false` | no |
| <a name="input_propagate_tags"></a> [propagate\_tags](#input\_propagate\_tags) | Whether to propagate the tags from the task definition or the service to the tasks | `string` | `"SERVICE"` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Health check grace period in seconds for the service when using load balancers | `number` | `null` | no |
| <a name="input_wait_for_steady_state"></a> [wait\_for\_steady\_state](#input\_wait\_for\_steady\_state) | Whether to wait for the service to reach a steady state before continuing | `bool` | `false` | no |
| <a name="input_force_new_deployment"></a> [force\_new\_deployment](#input\_force\_new\_deployment) | Whether to force a new task deployment of the service | `bool` | `false` | no |
| <a name="input_network_configuration"></a> [network\_configuration](#input\_network\_configuration) | Network configuration for the ECS service | <pre>object({<br/>    subnets          = list(string)<br/>    security_groups  = list(string)<br/>    assign_public_ip = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_load_balancer"></a> [load\_balancer](#input\_load\_balancer) | Load balancer configuration for the service | <pre>list(object({<br/>    target_group_arn = string<br/>    container_name   = string<br/>    container_port   = number<br/>  }))</pre> | `[]` | no |
| <a name="input_service_connect_configuration"></a> [service\_connect\_configuration](#input\_service\_connect\_configuration) | Service Connect configuration for the service | <pre>object({<br/>    enabled   = bool<br/>    namespace = optional(string)<br/>    log_configuration = optional(object({<br/>      log_driver = string<br/>      options    = map(string)<br/>    }))<br/>    service = optional(object({<br/>      client_alias = object({<br/>        dns_name = string<br/>        port     = number<br/>      })<br/>      discovery_name = string<br/>      port_name      = string<br/>      tls = optional(object({<br/>        issuer_cert_authority = object({<br/>          aws_pca_authority_arn = string<br/>        })<br/>        kms_key  = optional(string)<br/>        role_arn = optional(string)<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_service_registries"></a> [service\_registries](#input\_service\_registries) | Service discovery registries for the service | <pre>list(object({<br/>    registry_arn   = string<br/>    port           = optional(number)<br/>    container_name = optional(string)<br/>    container_port = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_service_connect_registry_arn"></a> [service\_connect\_registry\_arn](#input\_service\_connect\_registry\_arn) | ARN of the Service Connect service to register in service registries for external discovery | `string` | `null` | no |
| <a name="input_service_connect_registry_port"></a> [service\_connect\_registry\_port](#input\_service\_connect\_registry\_port) | Port value for the Service Connect service registry entry | `number` | `null` | no |
| <a name="input_service_connect_registry_container_name"></a> [service\_connect\_registry\_container\_name](#input\_service\_connect\_registry\_container\_name) | Container name for the Service Connect service registry entry | `string` | `null` | no |
| <a name="input_service_connect_registry_container_port"></a> [service\_connect\_registry\_container\_port](#input\_service\_connect\_registry\_container\_port) | Container port for the Service Connect service registry entry | `number` | `null` | no |
| <a name="input_service_connect_discovery_name"></a> [service\_connect\_discovery\_name](#input\_service\_connect\_discovery\_name) | Discovery name of the Service Connect service to lookup (should match service.discovery\_name in service\_connect\_configuration) | `string` | `null` | no |
| <a name="input_service_connect_namespace_id"></a> [service\_connect\_namespace\_id](#input\_service\_connect\_namespace\_id) | Namespace ID for Service Connect service discovery lookup | `string` | `null` | no |
| <a name="input_capacity_provider_strategy"></a> [capacity\_provider\_strategy](#input\_capacity\_provider\_strategy) | Capacity provider strategy to use for the service | <pre>list(object({<br/>    capacity_provider = string<br/>    weight            = number<br/>    base              = optional(number, 0)<br/>  }))</pre> | `[]` | no |
| <a name="input_deployment_configuration"></a> [deployment\_configuration](#input\_deployment\_configuration) | Deployment configuration for the service | <pre>object({<br/>    maximum_percent         = optional(number, 200)<br/>    minimum_healthy_percent = optional(number, 100)<br/>    deployment_circuit_breaker = optional(object({<br/>      enable   = bool<br/>      rollback = bool<br/>    }))<br/>    alarms = optional(object({<br/>      alarm_names = list(string)<br/>      enable      = bool<br/>      rollback    = bool<br/>    }))<br/>    deployment_attempts = optional(number, 2)<br/>  })</pre> | <pre>{<br/>  "maximum_percent": 200,<br/>  "minimum_healthy_percent": 100<br/>}</pre> | no |
| <a name="input_placement_constraints"></a> [placement\_constraints](#input\_placement\_constraints) | Placement constraints for the service | <pre>list(object({<br/>    type       = string<br/>    expression = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_ordered_placement_strategy"></a> [ordered\_placement\_strategy](#input\_ordered\_placement\_strategy) | Placement strategy for the service | <pre>list(object({<br/>    type  = string<br/>    field = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_volume_configuration"></a> [volume\_configuration](#input\_volume\_configuration) | Configuration for EBS volumes that are attached to tasks | <pre>object({<br/>    name = string<br/>    managed_ebs_volume = object({<br/>      role_arn         = string<br/>      encrypted        = optional(bool, true)<br/>      file_system_type = optional(string, "ext4")<br/>      iops             = optional(number)<br/>      kms_key_id       = optional(string)<br/>      size_in_gb       = optional(number, 20)<br/>      snapshot_id      = optional(string)<br/>      throughput       = optional(number)<br/>      volume_type      = optional(string, "gp3")<br/>      tag_specifications = optional(list(object({<br/>        resource_type = string<br/>        tags          = map(string)<br/>      })), [])<br/>    })<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the ECS service |
| <a name="output_name"></a> [name](#output\_name) | The name of the ECS service |
| <a name="output_cluster"></a> [cluster](#output\_cluster) | The cluster the ECS service is associated with |
| <a name="output_desired_count"></a> [desired\_count](#output\_desired\_count) | The desired number of tasks for the ECS service |
| <a name="output_task_definition"></a> [task\_definition](#output\_task\_definition) | The task definition ARN used by the ECS service |
| <a name="output_launch_type"></a> [launch\_type](#output\_launch\_type) | The launch type of the ECS service |
| <a name="output_platform_version"></a> [platform\_version](#output\_platform\_version) | The platform version of the ECS service |
| <a name="output_deployment_configuration"></a> [deployment\_configuration](#output\_deployment\_configuration) | The deployment configuration of the ECS service |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | The network configuration of the ECS service |
| <a name="output_load_balancer_configuration"></a> [load\_balancer\_configuration](#output\_load\_balancer\_configuration) | The load balancer configuration of the ECS service |
| <a name="output_service_connect_configuration"></a> [service\_connect\_configuration](#output\_service\_connect\_configuration) | The service connect configuration of the ECS service |
| <a name="output_service_registries"></a> [service\_registries](#output\_service\_registries) | The effective service registries configuration of the ECS service (includes Service Connect registry if configured) |
| <a name="output_service_connect_service_arn"></a> [service\_connect\_service\_arn](#output\_service\_connect\_service\_arn) | ARN of the Service Connect service discovered via data source (if lookup is configured) |
| <a name="output_service_connect_service_discovery_name"></a> [service\_connect\_service\_discovery\_name](#output\_service\_connect\_service\_discovery\_name) | Discovery name of the Service Connect service (from configuration) |
| <a name="output_capacity_provider_strategy"></a> [capacity_provider_strategy](#output\_capacity_provider_strategy) | The capacity provider strategy of the ECS service |
| <a name="output_placement_constraints"></a> [placement\_constraints](#output\_placement\_constraints) | The placement constraints of the ECS service |
| <a name="output_placement_strategy"></a> [placement\_strategy](#output\_placement\_strategy) | The placement strategy of the ECS service |
| <a name="output_volume_configuration"></a> [volume\_configuration](#output\_volume\_configuration) | The volume configuration of the ECS service |
| <a name="output_enable_execute_command"></a> [enable\_execute\_command](#output\_enable\_execute\_command) | Whether ECS Exec is enabled for the service |
| <a name="output_enable_ecs_managed_tags"></a> [enable\_ecs\_managed\_tags](#output\_enable\_ecs\_managed\_tags) | Whether ECS managed tags are enabled for the service |
| <a name="output_propagate_tags"></a> [propagate\_tags](#output\_propagate\_tags) | How tags are propagated to tasks |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of tags assigned to the ECS service |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including provider default\_tags |
| <a name="output_service_details"></a> [service\_details](#output\_service\_details) | Comprehensive details about the ECS service for integration purposes |
| <a name="output_service_configuration"></a> [service\_configuration](#output\_service\_configuration) | Summary of the ECS service configuration |
<!-- END_TF_DOCS -->