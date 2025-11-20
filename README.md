# ECS Service Primitive Module

This primitive module creates a single `aws_ecs_service` resource with comprehensive configuration options for deployment, networking, load balancing, and monitoring.

## Features

- **Comprehensive ECS Service Configuration**: Full support for all ECS service options
- **Network Configuration**: VPC networking with security groups and subnet assignment
- **Load Balancer Integration**: Support for Application Load Balancer and Network Load Balancer
- **Service Connect**: AWS Service Connect configuration for service-to-service communication
- **Service Discovery**: Integration with AWS Service Discovery for service registration
- **Capacity Provider Strategy**: Support for EC2 and Fargate capacity providers
- **Deployment Control**: Circuit breaker, rolling deployment, and alarm-based rollback
- **Placement Strategy**: Task placement constraints and strategies
- **Volume Management**: EBS volume configuration for persistent storage
- **Auto-scaling Ready**: Optional desired count lifecycle management
- **Comprehensive Validation**: Input validation for all configuration options

## Usage

### Basic ECS Service

```hcl
module "ecs_service" {
  source = "../../../primitives/ecs_service"

  name            = "my-app-service"
  cluster         = "arn:aws:ecs:us-west-2:123456789012:cluster/my-cluster"
  task_definition = "my-app-task:1"
  desired_count   = 2

  network_configuration = {
    subnets         = ["subnet-12345", "subnet-67890"]
    security_groups = ["sg-abcdef"]
    assign_public_ip = false
  }

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### ECS Service with Load Balancer

```hcl
module "ecs_service_with_alb" {
  source = "../../../primitives/ecs_service"

  name            = "web-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = data.aws_ecs_task_definition.web.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration = {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = false
  }

  load_balancer = [{
    target_group_arn = aws_lb_target_group.web.arn
    container_name   = "web-container"
    container_port   = 8080
  }]

  health_check_grace_period_seconds = 60

  deployment_configuration = {
    maximum_percent         = 200
    minimum_healthy_percent = 50
    deployment_circuit_breaker = {
      enable   = true
      rollback = true
    }
  }

  tags = {
    Environment = "production"
    Service     = "web"
  }
}
```

### ECS Service with Service Connect

```hcl
module "ecs_service_with_connect" {
  source = "../../../primitives/ecs_service"

  name            = "api-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = data.aws_ecs_task_definition.api.arn
  desired_count   = 2

  network_configuration = {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_service.id]
  }

  service_connect_configuration = {
    enabled   = true
    namespace = "my-app.local"

    log_configuration = {
      log_driver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/service-connect"
        "awslogs-region"        = "us-west-2"
        "awslogs-stream-prefix" = "ecs"
      }
    }

    service = {
      discovery_name = "api"
      port_name      = "http"
      client_alias = {
        dns_name = "api.my-app.local"
        port     = 8080
      }
    }
  }

  tags = {
    Environment = "production"
    Service     = "api"
  }
}
```

### ECS Service with Service Discovery

```hcl
module "ecs_service_with_discovery" {
  source = "../../../primitives/ecs_service"

  name            = "backend-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = data.aws_ecs_task_definition.backend.arn
  desired_count   = 2

  network_configuration = {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_service.id]
  }

  service_registries = [{
    registry_arn   = aws_service_discovery_service.backend.arn
    container_name = "backend-container"
    container_port = 8080
  }]

  tags = {
    Environment = "production"
    Service     = "backend"
  }
}
```

### ECS Service with Capacity Provider Strategy

```hcl
module "ecs_service_mixed_capacity" {
  source = "../../../primitives/ecs_service"

  name            = "batch-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = data.aws_ecs_task_definition.batch.arn
  desired_count   = 10

  network_configuration = {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_service.id]
  }

  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight           = 1
      base             = 2
    },
    {
      capacity_provider = "FARGATE_SPOT"
      weight           = 4
      base             = 0
    }
  ]

  tags = {
    Environment = "production"
    Service     = "batch"
  }
}
```

### ECS Service with Placement Strategy

```hcl
module "ecs_service_with_placement" {
  source = "../../../primitives/ecs_service"

  name            = "distributed-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = data.aws_ecs_task_definition.app.arn
  desired_count   = 6
  launch_type     = "EC2"

  network_configuration = {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_service.id]
  }

  placement_constraints = [{
    type       = "memberOf"
    expression = "attribute:ecs.instance-type =~ t3.*"
  }]

  ordered_placement_strategy = [
    {
      type  = "spread"
      field = "attribute:ecs.availability-zone"
    },
    {
      type  = "spread"
      field = "instanceId"
    }
  ]

  tags = {
    Environment = "production"
    Service     = "distributed"
  }
}
```

### ECS Service with EBS Volume

```hcl
module "ecs_service_with_storage" {
  source = "../../../primitives/ecs_service"

  name            = "data-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = data.aws_ecs_task_definition.data.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration = {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_service.id]
  }

  volume_configuration = {
    name = "data-volume"
    managed_ebs_volume = {
      role_arn         = aws_iam_role.ecs_volume.arn
      size_in_gb       = 100
      volume_type      = "gp3"
      encrypted        = true
      kms_key_id       = aws_kms_key.ecs.arn
      file_system_type = "ext4"

      tag_specifications = [{
        resource_type = "volume"
        tags = {
          Name = "data-service-volume"
          Environment = "production"
        }
      }]
    }
  }

  tags = {
    Environment = "production"
    Service     = "data"
  }
}
```

### Auto-scaling Ready Service

```hcl
module "ecs_service_autoscaling" {
  source = "../../../primitives/ecs_service"

  name            = "scalable-service"
  cluster         = data.aws_ecs_cluster.main.arn
  task_definition = data.aws_ecs_task_definition.app.arn
  desired_count   = 3

  network_configuration = {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.ecs_service.id]
  }

  # Ignore changes to desired_count for auto-scaling
  ignore_changes_desired_count = true

  deployment_configuration = {
    maximum_percent         = 200
    minimum_healthy_percent = 100
    deployment_circuit_breaker = {
      enable   = true
      rollback = true
    }
    alarms = {
      alarm_names = [aws_cloudwatch_metric_alarm.high_cpu.name]
      enable      = true
      rollback    = true
    }
  }

  tags = {
    Environment = "production"
    Service     = "scalable"
  }
}

# Auto-scaling target
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 2
  resource_id        = "service/${data.aws_ecs_cluster.main.cluster_name}/${module.ecs_service_autoscaling.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name for the ECS service | `string` | n/a | yes |
| cluster | ARN of the ECS cluster where this service will be placed | `string` | n/a | yes |
| task_definition | The family and revision or full ARN of the task definition | `string` | n/a | yes |
| desired_count | The number of instances of the task definition to place and keep running | `number` | `1` | no |
| launch_type | The launch type on which to run your service | `string` | `"FARGATE"` | no |
| platform_version | The platform version for FARGATE launch type | `string` | `"LATEST"` | no |
| iam_role | The ARN of an IAM role for the service | `string` | `null` | no |
| enable_execute_command | Whether to enable Amazon ECS Exec for the tasks | `bool` | `false` | no |
| enable_ecs_managed_tags | Whether to enable Amazon ECS managed tags for the tasks | `bool` | `false` | no |
| propagate_tags | Whether to propagate tags from task definition or service | `string` | `"SERVICE"` | no |
| health_check_grace_period_seconds | Health check grace period in seconds | `number` | `null` | no |
| wait_for_steady_state | Whether to wait for the service to reach steady state | `bool` | `false` | no |
| force_new_deployment | Whether to force a new task deployment | `bool` | `false` | no |
| network_configuration | Network configuration for the ECS service | `object` | `null` | no |
| load_balancer | Load balancer configuration for the service | `list(object)` | `[]` | no |
| service_connect_configuration | Service Connect configuration | `object` | `null` | no |
| service_registries | Service discovery registries | `list(object)` | `[]` | no |
| capacity_provider_strategy | Capacity provider strategy | `list(object)` | `[]` | no |
| deployment_configuration | Deployment configuration | `object` | `{maximum_percent=200, minimum_healthy_percent=100}` | no |
| placement_constraints | Placement constraints | `list(object)` | `[]` | no |
| ordered_placement_strategy | Placement strategy | `list(object)` | `[]` | no |
| volume_configuration | EBS volume configuration | `object` | `null` | no |
| ignore_changes_desired_count | Whether to ignore changes to desired_count | `bool` | `false` | no |
| depends_on_iam_policies | List of IAM policy ARNs to depend on | `list(string)` | `[]` | no |
| tags | A map of tags to add to the ECS service | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the ECS service |
| name | The name of the ECS service |
| arn | The ARN of the ECS service |
| cluster | The cluster the ECS service is associated with |
| desired_count | The number of running tasks for the ECS service |
| running_count | The number of running tasks for the ECS service |
| pending_count | The number of pending tasks for the ECS service |
| task_definition | The task definition ARN used by the ECS service |
| launch_type | The launch type of the ECS service |
| platform_version | The platform version of the ECS service |
| deployment_configuration | The deployment configuration of the ECS service |
| network_configuration | The network configuration of the ECS service |
| load_balancer_configuration | The load balancer configuration of the ECS service |
| service_connect_configuration | The service connect configuration of the ECS service |
| service_registries | The service registries configuration |
| capacity_provider_strategy | The capacity provider strategy |
| placement_constraints | The placement constraints |
| placement_strategy | The placement strategy |
| volume_configuration | The volume configuration |
| service_details | Comprehensive details about the ECS service |
| service_configuration | Summary of the ECS service configuration |
| tags | A map of tags assigned to the ECS service |
| tags_all | A map of tags assigned including provider defaults |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Architecture

This module creates a comprehensive ECS service with support for:

- **Launch Types**: FARGATE, EC2, and EXTERNAL
- **Networking**: VPC mode with security groups and subnet configuration
- **Load Balancing**: Application and Network Load Balancer integration
- **Service Discovery**: AWS Service Discovery and Service Connect
- **Deployment**: Rolling deployments with circuit breaker and alarm-based rollback
- **Scaling**: Integration with Application Auto Scaling
- **Storage**: EBS volume management for persistent data
- **Placement**: Fine-grained control over task placement
- **Monitoring**: CloudWatch integration and ECS Exec support

## Best Practices

1. **Use FARGATE for most workloads** unless you need specific EC2 features
2. **Enable deployment circuit breaker** for production services
3. **Configure health check grace period** when using load balancers
4. **Use Service Connect** for service-to-service communication
5. **Set ignore_changes_desired_count** when using auto-scaling
6. **Configure proper placement strategy** for high availability
7. **Use KMS encryption** for EBS volumes containing sensitive data
8. **Set appropriate resource tags** for cost tracking and management

## Security Considerations

- Configure security groups to restrict network access
- Use IAM roles with least privilege for task execution
- Enable KMS encryption for EBS volumes
- Use private subnets for internal services
- Configure Service Connect with TLS for secure communication
- Enable logging for audit and troubleshooting

## Performance Optimization

- Use FARGATE_SPOT for cost-effective workloads
- Configure appropriate placement strategy for distributed workloads
- Use GP3 volumes for better price-performance ratio
- Set deployment configuration for faster or safer deployments
- Monitor service metrics and configure auto-scaling appropriately

---

## What is a Primitive Module?

A **primitive module** is a thin, focused Terraform wrapper around a single AWS resource type. Primitive modules:

- Wrap a **single AWS resource** (e.g., `aws_eks_cluster`, `aws_kms_key`, `aws_s3_bucket`)
- Provide sensible defaults while maintaining full configurability
- Include comprehensive validation rules
- Follow consistent patterns for inputs, outputs, and tagging
- Include automated testing using Terratest
- Serve as building blocks for higher-level composite modules

For examples of well-structured primitive modules, see:

- [tf-aws-module_primitive-eks_cluster](https://github.com/launchbynttdata/tf-aws-module_primitive-eks_cluster)
- [tf-aws-module_primitive-kms_key](https://github.com/launchbynttdata/tf-aws-module_primitive-kms_key)

---

## Getting Started with This Template

### 1. Create Your New Module Repository

1. Click the "Use this template" button on GitHub
2. Name your repository following the naming convention: `tf-aws-module_primitive-<resource_name>`
   - Examples: `tf-aws-module_primitive-s3_bucket`, `tf-aws-module_primitive-lambda_function`
3. Clone your new repository locally

### 2. Initialize and Clean Up Template References

After cloning, run the cleanup target to update template references with your actual repository information:

```bash
make init-module
```

This command will:

- Update the `go.mod` file with your repository's GitHub URL
- Update test imports to reference your new module name
- Remove template-specific placeholders

### 3. Configure Your Environment

Install required development dependencies:

```bash
make configure-dependencies
make configure-git-hooks
```

This installs:

- Terraform
- Go
- Pre-commit hooks
- Other development tools specified in `.tool-versions`

---

## HOWTO: Developing a Primitive Module

### Step 1: Define Your Resource

1. **Identify the AWS resource** you're wrapping (e.g., `aws_eks_cluster`)
2. **Review AWS documentation** for the resource to understand all available parameters
3. **Study similar primitive modules** for patterns and best practices

### Step 2: Create the Module Structure

Your primitive module should include these core files:

#### `main.tf`

- Contains the primary resource declaration
- Should be clean and focused on the single resource
- Example:

```hcl
resource "aws_eks_cluster" "this" {
  name     = var.name
  role_arn = var.role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.vpc_config.subnet_ids
    security_group_ids      = var.vpc_config.security_group_ids
    endpoint_private_access = var.vpc_config.endpoint_private_access
    endpoint_public_access  = var.vpc_config.endpoint_public_access
    public_access_cidrs     = var.vpc_config.public_access_cidrs
  }

  tags = merge(
    var.tags,
    local.default_tags
  )
}
```

#### `variables.tf`

- Define all configurable parameters
- Include clear descriptions for each variable
- Set sensible defaults where appropriate
- Use validation rules to enforce constraints, but only when the validations can be made precise.
- Alternatively, use [`check`](https://developer.hashicorp.com/terraform/language/block/check) blocks to create more complicated validations. (Requires terraform ~> 1.12)
- Example:

```hcl
variable "name" {
  description = "Name of the EKS cluster"
  type        = string

  validation {
    condition     = length(var.name) <= 100
    error_message = "Cluster name must be 100 characters or less"
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = null

  validation {
    condition     = var.kubernetes_version == null || can(regex("^1\\.(2[89]|[3-9][0-9])$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.28 or higher"
  }
}
```

#### `outputs.tf`

- Export all useful attributes of the resource
- Include comprehensive outputs for downstream consumption
- Document what each output provides
- Example:

```hcl
output "id" {
  description = "The ID of the EKS cluster"
  value       = aws_eks_cluster.this.id
}

output "arn" {
  description = "The ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.this.endpoint
}
```

#### `locals.tf`

- Define local values and transformations
- Include standard tags (e.g., `provisioner = "Terraform"`)
- Example:

```hcl
locals {
  default_tags = {
    provisioner = "Terraform"
  }
}
```

#### `versions.tf`

- Specify required Terraform and provider versions
- Example:

```hcl
terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}
```

### Step 3: Create Examples

Create example configurations in the `examples/` directory:

#### `examples/simple/`

- Minimal, working configuration
- Uses only required variables
- Good for quick starts and basic testing

#### `examples/complete/`

- Comprehensive configuration showing all features
- Demonstrates advanced options
- Includes comments explaining choices

Each example should include:

- `main.tf` - The module invocation
- `variables.tf` - Example variables
- `outputs.tf` - Pass-through outputs
- `test.tfvars` - Test values for automated testing
- `README.md` - Documentation for the example

### Step 4: Write Tests

Update the test files in `tests/`:

#### `tests/testimpl/test_impl.go`

Write functional tests that verify:

- The resource is created successfully
- Resource properties match expectations
- Outputs are correct
- Integration with AWS SDK to verify actual state

#### `tests/testimpl/types.go`

Define the configuration structure for your tests:

```go
type ThisTFModuleConfig struct {
    Name              string `json:"name"`
    KubernetesVersion string `json:"kubernetes_version"`
    // ... other fields
}
```

#### `tests/post_deploy_functional/main_test.go`

- Update test names to match your module
- Configure test flags (e.g., idempotency settings)
- Adjust test context as needed

### Step 5: Update Documentation

1. **Update README.md** with:
   - Overview of the module
   - Feature list
   - Usage examples
   - Input/output documentation
   - Validation rules

2. **Document validation rules** clearly so users understand constraints.

### Step 6: Test Your Module

1. **Run local validation**:

```bash
make check
```

This runs:

- Terraform fmt, validate, and plan
- Go tests with Terratest
- Pre-commit hooks
- Security scans

1. **Test with real infrastructure**:

```bash
cd examples/simple
terraform init
terraform plan -var-file=test.tfvars -out=the.tfplan
terraform apply the.tfplan
```

1. **Verify outputs**:

```bash
terraform output
```

1. **Clean up**:

```bash
terraform destroy -var-file=test.tfvars
```

### Step 7: Document and Release

1. **Write a comprehensive README** following the pattern in the example modules
1. **Add files to commit** `git add .`
1. **Run pre-commit hooks manually** `pre-commit run`
1. **Resolve any pre-commit issues**
1. **Push branch to github**

---

## Module Best Practices

### Naming Conventions

- Repository: `tf-aws-module_primitive-<resource_name>`
- Resource identifier: Use `this` for the primary resource.
- Variables: Use snake_case.
- Match AWS resource parameter names where possible.

### Input Variables

- Provide sensible defaults when safe to do so.
- Use `null` as default for optional complex objects.
- Include validation rules with clear error messages.
- Group related parameters using object types.
- Document expected formats and constraints.

### Outputs

- Export all significant resource attributes.
- Use clear, descriptive output names.
- Include descriptions for all outputs.
- Consider downstream module needs.

### Tags

- Always include a `tags` variable, unless the resource does not support tags.
- Merge with `local.default_tags` including `provisioner = "Terraform"`.
- Use provider default tags when appropriate.

### Validation

- Validate input constraints at the variable level.
- Provide helpful error messages.
- Check for common misconfigurations.
- Validate relationships between variables.

### Testing

- Test the minimal example (required parameters only).
- Test the complete example (all features).
- Verify resource creation and properties.
- Test idempotency where applicable.
- Test validation rules by expecting failures.

### Documentation

- Clear overview of the module's purpose.
- Feature list highlighting key capabilities.
- Multiple usage examples (minimal and complete).
- Comprehensive input/output tables.
- Document validation rules and constraints.
- Include links to relevant AWS documentation.

---

## File Structure

After initialization, your module should have this structure:

```
tf-aws-module_primitive-<resource_name>/
├── .github/
│   └── workflows/          # CI/CD workflows
├── examples/
│   ├── simple/            # Minimal example
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── test.tfvars
│   │   └── README.md
│   └── complete/          # Comprehensive example
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── test.tfvars
│       └── README.md
├── tests/
│   ├── post_deploy_functional/
│   │   └── main_test.go
│   ├── testimpl/
│   │   ├── test_impl.go
│   │   └── types.go
├── .gitignore
├── .pre-commit-config.yaml
├── .tool-versions
├── go.mod
├── go.sum
├── LICENSE
├── locals.tf
├── main.tf
├── Makefile
├── outputs.tf
├── README.md
├── variables.tf
└── versions.tf
```

---

## Common Makefile Targets

| Target | Description |
|--------|-------------|
| `make init-module` | Initialize new module from template (run once after creating from template) |
| `make configure-dependencies` | Install required development tools |
| `make configure-git-hooks` | Set up pre-commit hooks |
| `make check` | Run all validation and tests |
| `make configure` | Full setup (dependencies + hooks + repo sync) |
| `make clean` | Remove downloaded components |

---

## Getting Help

- Review example modules: [EKS Cluster](https://github.com/launchbynttdata/tf-aws-module_primitive-eks_cluster), [KMS Key](https://github.com/launchbynttdata/tf-aws-module_primitive-kms_key)
- Check the Launch Common Automation Framework documentation.
- Reach out to the platform team for guidance.

---

## Contributing

Follow the established patterns in existing primitive modules. All modules should:

- Pass `make check` validation.
- Include comprehensive tests.
- Follow naming conventions.
- Include clear documentation.
- Use semantic versioning.

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
| <a name="output_capacity_provider_strategy"></a> [capacity\_provider\_strategy](#output\_capacity\_provider\_strategy) | The capacity provider strategy of the ECS service |
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
