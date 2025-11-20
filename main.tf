# =======================================================================
# ECS SERVICE PRIMITIVE MODULE
# =======================================================================
# This module creates a single aws_ecs_service resource with comprehensive
# configuration options for deployment, networking, load balancing, and monitoring.
# =======================================================================

# Main ECS Service Resource
resource "aws_ecs_service" "this" {
  name             = var.name
  cluster          = var.cluster
  task_definition  = var.task_definition
  desired_count    = var.desired_count
  launch_type      = var.launch_type
  platform_version = local.effective_platform_version
  iam_role         = var.iam_role

  # Service Management
  enable_execute_command            = var.enable_execute_command
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  propagate_tags                    = var.propagate_tags
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  wait_for_steady_state             = var.wait_for_steady_state
  force_new_deployment              = var.force_new_deployment

  # Network Configuration (conditional)
  dynamic "network_configuration" {
    for_each = local.has_network_configuration ? [var.network_configuration] : []
    content {
      subnets          = network_configuration.value.subnets
      security_groups  = network_configuration.value.security_groups
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  # Load Balancer Configuration (conditional)
  dynamic "load_balancer" {
    for_each = var.load_balancer
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # Service Connect Configuration (conditional)
  dynamic "service_connect_configuration" {
    for_each = local.service_connect_enabled ? [var.service_connect_configuration] : []
    content {
      enabled   = service_connect_configuration.value.enabled
      namespace = service_connect_configuration.value.namespace

      # Log Configuration (conditional)
      dynamic "log_configuration" {
        for_each = service_connect_configuration.value.log_configuration != null ? [service_connect_configuration.value.log_configuration] : []
        content {
          log_driver = log_configuration.value.log_driver
          options    = log_configuration.value.options
        }
      }

      # Service Configuration (conditional)
      dynamic "service" {
        for_each = local.service_connect_service_configured ? [service_connect_configuration.value.service] : []
        content {
          client_alias {
            dns_name = service.value.client_alias.dns_name
            port     = service.value.client_alias.port
          }
          discovery_name = service.value.discovery_name
          port_name      = service.value.port_name

          # TLS Configuration (conditional)
          dynamic "tls" {
            for_each = service.value.tls != null ? [service.value.tls] : []
            content {
              issuer_cert_authority {
                aws_pca_authority_arn = tls.value.issuer_cert_authority.aws_pca_authority_arn
              }
              kms_key  = tls.value.kms_key
              role_arn = tls.value.role_arn
            }
          }
        }
      }
    }
  }

  # Service Registries (conditional)
  dynamic "service_registries" {
    for_each = local.effective_service_registries
    content {
      registry_arn   = service_registries.value.registry_arn
      port           = service_registries.value.port
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
    }
  }

  # Capacity Provider Strategy (conditional)
  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = capacity_provider_strategy.value.base
    }
  }

  # Deployment Configuration (direct attributes)
  deployment_maximum_percent         = var.deployment_configuration.maximum_percent
  deployment_minimum_healthy_percent = var.deployment_configuration.minimum_healthy_percent

  # Deployment Circuit Breaker (conditional)
  dynamic "deployment_circuit_breaker" {
    for_each = local.deployment_circuit_breaker_enabled ? [var.deployment_configuration.deployment_circuit_breaker] : []
    content {
      enable   = deployment_circuit_breaker.value.enable
      rollback = deployment_circuit_breaker.value.rollback
    }

  }

  # Alarms Configuration (conditional)
  dynamic "alarms" {
    for_each = local.deployment_alarms_enabled ? [var.deployment_configuration.alarms] : []
    content {
      alarm_names = alarms.value.alarm_names
      enable      = alarms.value.enable
      rollback    = alarms.value.rollback
    }
  }

  # Placement Constraints (conditional)
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  # Ordered Placement Strategy (conditional)
  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  # Volume Configuration (conditional)
  dynamic "volume_configuration" {
    for_each = local.has_volume_configuration ? [var.volume_configuration] : []
    content {
      name = volume_configuration.value.name

      managed_ebs_volume {
        encrypted        = volume_configuration.value.managed_ebs_volume.encrypted
        file_system_type = volume_configuration.value.managed_ebs_volume.file_system_type
        iops             = volume_configuration.value.managed_ebs_volume.iops
        kms_key_id       = volume_configuration.value.managed_ebs_volume.kms_key_id
        role_arn         = volume_configuration.value.managed_ebs_volume.role_arn
        size_in_gb       = volume_configuration.value.managed_ebs_volume.size_in_gb
        snapshot_id      = volume_configuration.value.managed_ebs_volume.snapshot_id
        throughput       = volume_configuration.value.managed_ebs_volume.throughput
        volume_type      = volume_configuration.value.managed_ebs_volume.volume_type

        dynamic "tag_specifications" {
          for_each = volume_configuration.value.managed_ebs_volume.tag_specifications
          content {
            resource_type = tag_specifications.value.resource_type
            tags          = tag_specifications.value.tags
          }
        }
      }
    }
  }

  # Tags
  tags = local.final_tags
}
