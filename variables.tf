# =======================================================================
# ECS SERVICE PRIMITIVE MODULE - VARIABLES
# =======================================================================
# This file defines all input variables for the ECS service primitive module.
# It creates a single aws_ecs_service resource with all its configuration options.
# =======================================================================

# Core Configuration
variable "name" {
  description = "Name for the ECS service"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 255
    error_message = "Service name must be between 1 and 255 characters."
  }
}

variable "tags" {
  description = "A map of tags to add to the ECS service"
  type        = map(string)
  default     = {}
}

# Core ECS Service Configuration
variable "cluster" {
  description = "ARN of the ECS cluster where this service will be placed"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:ecs:[a-z0-9-]+:[0-9]{12}:cluster/.+", var.cluster))
    error_message = "Cluster must be a valid ECS cluster ARN."
  }
}

variable "task_definition" {
  description = "The family and revision (family:revision) or full ARN of the task definition to run in your service"
  type        = string

  validation {
    condition     = length(var.task_definition) > 0
    error_message = "Task definition must be specified."
  }
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 0
    error_message = "Desired count must be non-negative."
  }
}

variable "launch_type" {
  description = "The launch type on which to run your service. Valid values: EC2, FARGATE, EXTERNAL"
  type        = string
  default     = "FARGATE"

  validation {
    condition     = contains(["EC2", "FARGATE", "EXTERNAL"], var.launch_type)
    error_message = "Launch type must be one of: EC2, FARGATE, EXTERNAL."
  }
}

variable "platform_version" {
  description = "The platform version on which to run your service. Only applicable for launch_type set to FARGATE"
  type        = string
  default     = "LATEST"
}

variable "iam_role" {
  description = "The ARN of an IAM role that allows your Amazon ECS service to make calls to other AWS services"
  type        = string
  default     = null
}

# Service Management
variable "enable_execute_command" {
  description = "Whether to enable Amazon ECS Exec for the tasks in the service"
  type        = bool
  default     = false
}

variable "enable_ecs_managed_tags" {
  description = "Whether to enable Amazon ECS managed tags for the tasks in the service"
  type        = bool
  default     = false
}

variable "propagate_tags" {
  description = "Whether to propagate the tags from the task definition or the service to the tasks"
  type        = string
  default     = "SERVICE"

  validation {
    condition     = contains(["TASK_DEFINITION", "SERVICE", "NONE"], var.propagate_tags)
    error_message = "Propagate tags must be one of: TASK_DEFINITION, SERVICE, NONE."
  }
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period in seconds for the service when using load balancers"
  type        = number
  default     = null

  validation {
    condition     = var.health_check_grace_period_seconds == null || (var.health_check_grace_period_seconds >= 0 && var.health_check_grace_period_seconds <= 2147483647)
    error_message = "Health check grace period must be between 0 and 2147483647 seconds."
  }
}

variable "wait_for_steady_state" {
  description = "Whether to wait for the service to reach a steady state before continuing"
  type        = bool
  default     = false
}

variable "force_new_deployment" {
  description = "Whether to force a new task deployment of the service"
  type        = bool
  default     = false
}

# Network Configuration
variable "network_configuration" {
  description = "Network configuration for the ECS service"
  type = object({
    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = optional(bool, false)
  })
  default = null

  validation {
    condition = var.network_configuration == null || (
      length(var.network_configuration.subnets) > 0 &&
      alltrue([for subnet in var.network_configuration.subnets : can(regex("^subnet-[a-z0-9]+$", subnet))])
    )
    error_message = "Network configuration subnets must be valid subnet IDs when specified."
  }

  validation {
    condition = var.network_configuration == null || (
      alltrue([for sg in var.network_configuration.security_groups : can(regex("^sg-[a-z0-9]+$", sg))])
    )
    error_message = "Network configuration security groups must be valid security group IDs when specified."
  }
}

# Load Balancer Configuration
variable "load_balancer" {
  description = "Load balancer configuration for the service"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []

  validation {
    condition = alltrue([
      for lb in var.load_balancer : can(regex("^arn:aws:elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:targetgroup/.+", lb.target_group_arn))
    ])
    error_message = "Load balancer target group ARNs must be valid."
  }

  validation {
    condition = alltrue([
      for lb in var.load_balancer : lb.container_port > 0 && lb.container_port <= 65535
    ])
    error_message = "Load balancer container ports must be between 1 and 65535."
  }
}

# Service Connect Configuration
variable "service_connect_configuration" {
  description = "Service Connect configuration for the service"
  type = object({
    enabled   = bool
    namespace = optional(string)
    log_configuration = optional(object({
      log_driver = string
      options    = map(string)
    }))
    service = optional(object({
      client_alias = object({
        dns_name = string
        port     = number
      })
      discovery_name = string
      port_name      = string
      tls = optional(object({
        issuer_cert_authority = object({
          aws_pca_authority_arn = string
        })
        kms_key  = optional(string)
        role_arn = optional(string)
      }))
    }))
  })
  default = null
}

# Service Registry Configuration
variable "service_registries" {
  description = "Service discovery registries for the service"
  type = list(object({
    registry_arn   = string
    port           = optional(number)
    container_name = optional(string)
    container_port = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for sr in var.service_registries : can(regex("^arn:aws:servicediscovery:[a-z0-9-]+:[0-9]{12}:service/.+", sr.registry_arn))
    ])
    error_message = "Service registry ARNs must be valid Service Discovery service ARNs."
  }
}

# Service Connect Registry Integration
variable "service_connect_registry_arn" {
  description = "ARN of the Service Connect service to register in service registries for external discovery"
  type        = string
  default     = null

  validation {
    condition     = var.service_connect_registry_arn == null || can(regex("^arn:aws:servicediscovery:[a-z0-9-]+:[0-9]{12}:service/.+", var.service_connect_registry_arn))
    error_message = "Service Connect registry ARN must be a valid Service Discovery service ARN."
  }
}

variable "service_connect_registry_port" {
  description = "Port value for the Service Connect service registry entry"
  type        = number
  default     = null
}

variable "service_connect_registry_container_name" {
  description = "Container name for the Service Connect service registry entry"
  type        = string
  default     = null
}

variable "service_connect_registry_container_port" {
  description = "Container port for the Service Connect service registry entry"
  type        = number
  default     = null
}

# Service Connect Discovery Variables (for data source lookup)
variable "service_connect_discovery_name" {
  description = "Discovery name of the Service Connect service to lookup (should match service.discovery_name in service_connect_configuration)"
  type        = string
  default     = null
}

variable "service_connect_namespace_id" {
  description = "Namespace ID for Service Connect service discovery lookup"
  type        = string
  default     = null
}

# Capacity Provider Strategy
variable "capacity_provider_strategy" {
  description = "Capacity provider strategy to use for the service"
  type = list(object({
    capacity_provider = string
    weight            = number
    base              = optional(number, 0)
  }))
  default = []

  validation {
    condition = alltrue([
      for cps in var.capacity_provider_strategy : cps.weight >= 0 && cps.weight <= 1000
    ])
    error_message = "Capacity provider strategy weight must be between 0 and 1000."
  }

  validation {
    condition = alltrue([
      for cps in var.capacity_provider_strategy : cps.base >= 0 && cps.base <= 10000
    ])
    error_message = "Capacity provider strategy base must be between 0 and 10000."
  }
}

# Deployment Configuration
variable "deployment_configuration" {
  description = "Deployment configuration for the service"
  type = object({
    maximum_percent         = optional(number, 200)
    minimum_healthy_percent = optional(number, 100)
    deployment_circuit_breaker = optional(object({
      enable   = bool
      rollback = bool
    }))
    alarms = optional(object({
      alarm_names = list(string)
      enable      = bool
      rollback    = bool
    }))
    deployment_attempts = optional(number, 2)
  })
  default = {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  validation {
    condition     = var.deployment_configuration.maximum_percent >= 100 && var.deployment_configuration.maximum_percent <= 200
    error_message = "Deployment maximum percent must be between 100 and 200."
  }

  validation {
    condition     = var.deployment_configuration.minimum_healthy_percent >= 0 && var.deployment_configuration.minimum_healthy_percent <= 100
    error_message = "Deployment minimum healthy percent must be between 0 and 100."
  }
}

# Placement Configuration
variable "placement_constraints" {
  description = "Placement constraints for the service"
  type = list(object({
    type       = string
    expression = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for pc in var.placement_constraints : contains(["distinctInstance", "memberOf"], pc.type)
    ])
    error_message = "Placement constraint type must be 'distinctInstance' or 'memberOf'."
  }
}

variable "ordered_placement_strategy" {
  description = "Placement strategy for the service"
  type = list(object({
    type  = string
    field = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for ops in var.ordered_placement_strategy : contains(["random", "spread", "binpack"], ops.type)
    ])
    error_message = "Ordered placement strategy type must be 'random', 'spread', or 'binpack'."
  }
}

# Volume Configuration
variable "volume_configuration" {
  description = "Configuration for EBS volumes that are attached to tasks"
  type = object({
    name = string
    managed_ebs_volume = object({
      role_arn         = string
      encrypted        = optional(bool, true)
      file_system_type = optional(string, "ext4")
      iops             = optional(number)
      kms_key_id       = optional(string)
      size_in_gb       = optional(number, 20)
      snapshot_id      = optional(string)
      throughput       = optional(number)
      volume_type      = optional(string, "gp3")
      tag_specifications = optional(list(object({
        resource_type = string
        tags          = map(string)
      })), [])
    })
  })
  default = null

  validation {
    condition = var.volume_configuration == null || (
      var.volume_configuration.managed_ebs_volume.size_in_gb >= 1 &&
      var.volume_configuration.managed_ebs_volume.size_in_gb <= 16384
    )
    error_message = "EBS volume size must be between 1 and 16384 GB."
  }

  validation {
    condition = var.volume_configuration == null || contains([
      "standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"
    ], var.volume_configuration.managed_ebs_volume.volume_type)
    error_message = "EBS volume type must be one of: standard, gp2, gp3, io1, io2, sc1, st1."
  }
}
