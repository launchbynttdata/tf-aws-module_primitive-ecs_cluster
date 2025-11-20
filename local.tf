# =======================================================================
# ECS SERVICE PRIMITIVE MODULE - LOCAL VALUES
# =======================================================================
# This file contains local value definitions for the ECS service primitive module.
# =======================================================================

locals {
  # Deployment configuration processing
  deployment_circuit_breaker_enabled = var.deployment_configuration.deployment_circuit_breaker != null
  deployment_alarms_enabled          = var.deployment_configuration.alarms != null

  # Network configuration validation
  has_network_configuration = var.network_configuration != null

  # Service Connect configuration processing
  service_connect_enabled            = var.service_connect_configuration != null && var.service_connect_configuration.enabled
  service_connect_service_configured = local.service_connect_enabled && var.service_connect_configuration.service != null

  # Load balancer configuration processing
  has_load_balancer = length(var.load_balancer) > 0

  # Capacity provider strategy processing
  has_capacity_provider_strategy = length(var.capacity_provider_strategy) > 0

  # Placement configuration processing
  has_placement_constraints = length(var.placement_constraints) > 0
  has_placement_strategy    = length(var.ordered_placement_strategy) > 0

  # Service registry configuration processing
  has_service_registries = length(var.service_registries) > 0

  # Service Connect service registry integration
  # When service_connect_registry_arn is provided, create an additional service registry entry
  # This allows users to manually specify the Service Connect service ARN for traditional service discovery
  service_connect_registry_entry = var.service_connect_registry_arn != null ? [
    {
      registry_arn   = var.service_connect_registry_arn
      port           = var.service_connect_registry_port
      container_name = var.service_connect_registry_container_name
      container_port = var.service_connect_registry_container_port
    }
  ] : []

  # Combine explicit service registries with Service Connect registry (if provided)
  effective_service_registries = concat(var.service_registries, local.service_connect_registry_entry)

  # Volume configuration processing
  has_volume_configuration = var.volume_configuration != null

  # Tags processing
  default_tags = {
    Name      = var.name
    ManagedBy = "Terraform"
    Module    = "ecs-service-primitive"
  }

  final_tags = merge(local.default_tags, var.tags)

  # Validation helpers
  fargate_launch_type = var.launch_type == "FARGATE"
  ec2_launch_type     = var.launch_type == "EC2"

  # Platform version validation - only applies to FARGATE
  effective_platform_version = local.fargate_launch_type ? var.platform_version : null
}
