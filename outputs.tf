// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

# =======================================================================
# ECS SERVICE PRIMITIVE MODULE - OUTPUTS
# =======================================================================
# This file defines all outputs for the ECS service primitive module.
# =======================================================================

# Core Service Information
output "id" {
  description = "The ID of the ECS service"
  value       = aws_ecs_service.this.id
}

output "name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "cluster" {
  description = "The cluster the ECS service is associated with"
  value       = aws_ecs_service.this.cluster
}

output "desired_count" {
  description = "The desired number of tasks for the ECS service"
  value       = aws_ecs_service.this.desired_count
}

output "task_definition" {
  description = "The task definition ARN used by the ECS service"
  value       = aws_ecs_service.this.task_definition
}

output "launch_type" {
  description = "The launch type of the ECS service"
  value       = aws_ecs_service.this.launch_type
}

output "platform_version" {
  description = "The platform version of the ECS service"
  value       = aws_ecs_service.this.platform_version
}

# Configuration Information
output "deployment_configuration" {
  description = "The deployment configuration of the ECS service"
  value = {
    maximum_percent         = aws_ecs_service.this.deployment_maximum_percent
    minimum_healthy_percent = aws_ecs_service.this.deployment_minimum_healthy_percent
  }
}

output "network_configuration" {
  description = "The network configuration of the ECS service"
  value = local.has_network_configuration ? {
    subnets          = var.network_configuration.subnets
    security_groups  = var.network_configuration.security_groups
    assign_public_ip = var.network_configuration.assign_public_ip
  } : null
}

output "load_balancer_configuration" {
  description = "The load balancer configuration of the ECS service"
  value       = local.has_load_balancer ? var.load_balancer : []
}

output "service_connect_configuration" {
  description = "The service connect configuration of the ECS service"
  value       = local.service_connect_enabled ? var.service_connect_configuration : null
}

output "service_registries" {
  description = "The effective service registries configuration of the ECS service (includes Service Connect registry if configured)"
  value       = local.effective_service_registries
}

# Service Connect Integration Outputs
output "service_connect_service_arn" {
  description = "ARN of the Service Connect service discovered via data source (if lookup is configured)"
  value       = local.service_connect_service_configured && var.service_connect_discovery_name != null ? try(data.aws_service_discovery_service.service_connect[0].arn, null) : null
}

output "service_connect_service_discovery_name" {
  description = "Discovery name of the Service Connect service (from configuration)"
  value       = local.service_connect_service_configured ? var.service_connect_configuration.service.discovery_name : null
}

output "capacity_provider_strategy" {
  description = "The capacity provider strategy of the ECS service"
  value       = local.has_capacity_provider_strategy ? var.capacity_provider_strategy : []
}

output "placement_constraints" {
  description = "The placement constraints of the ECS service"
  value       = local.has_placement_constraints ? var.placement_constraints : []
}

output "placement_strategy" {
  description = "The placement strategy of the ECS service"
  value       = local.has_placement_strategy ? var.ordered_placement_strategy : []
}

output "volume_configuration" {
  description = "The volume configuration of the ECS service"
  value       = local.has_volume_configuration ? var.volume_configuration : null
}

# Service Status and Health
output "enable_execute_command" {
  description = "Whether ECS Exec is enabled for the service"
  value       = aws_ecs_service.this.enable_execute_command
}

output "enable_ecs_managed_tags" {
  description = "Whether ECS managed tags are enabled for the service"
  value       = aws_ecs_service.this.enable_ecs_managed_tags
}

output "propagate_tags" {
  description = "How tags are propagated to tasks"
  value       = aws_ecs_service.this.propagate_tags
}

# Tags
output "tags" {
  description = "A map of tags assigned to the ECS service"
  value       = aws_ecs_service.this.tags
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including provider default_tags"
  value       = aws_ecs_service.this.tags_all
}

# Service Details for Integration
output "service_details" {
  description = "Comprehensive details about the ECS service for integration purposes"
  value = {
    id                     = aws_ecs_service.this.id
    name                   = aws_ecs_service.this.name
    cluster                = aws_ecs_service.this.cluster
    task_definition        = aws_ecs_service.this.task_definition
    desired_count          = aws_ecs_service.this.desired_count
    launch_type            = aws_ecs_service.this.launch_type
    platform_version       = aws_ecs_service.this.platform_version
    enable_execute_command = aws_ecs_service.this.enable_execute_command
    propagate_tags         = aws_ecs_service.this.propagate_tags
  }
}

# Configuration Summary
output "service_configuration" {
  description = "Summary of the ECS service configuration"
  value = {
    name                           = var.name
    cluster                        = var.cluster
    task_definition                = var.task_definition
    desired_count                  = var.desired_count
    launch_type                    = var.launch_type
    platform_version               = local.effective_platform_version
    has_network_configuration      = local.has_network_configuration
    has_load_balancer              = local.has_load_balancer
    service_connect_enabled        = local.service_connect_enabled
    has_service_registries         = local.has_service_registries
    has_capacity_provider_strategy = local.has_capacity_provider_strategy
    has_placement_constraints      = local.has_placement_constraints
    has_placement_strategy         = local.has_placement_strategy
    has_volume_configuration       = local.has_volume_configuration
  }
}
