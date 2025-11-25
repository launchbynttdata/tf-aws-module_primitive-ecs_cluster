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
# ECS CLUSTER PRIMITIVE MODULE - VARIABLES
# =======================================================================
# This file defines all input variables for the ECS cluster primitive module.
# It creates a single aws_ecs_cluster resource with all its configuration options.
# =======================================================================

# Core Configuration
variable "name" {
  description = "Name of the ECS cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 255 && can(regex("^[a-zA-Z0-9_-]+$", var.name))
    error_message = "Cluster name must be between 1 and 255 characters and contain only letters, numbers, hyphens, and underscores."
  }
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
  default     = {}
}

# Settings Configuration
variable "settings" {
  description = "Configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster"
  type = list(object({
    name  = string
    value = string
  }))
  default = []

  validation {
    condition = alltrue([
      for setting in var.settings : contains([
        "containerInsights",
        "containerInstanceLongArnFormat",
        "taskLongArnFormat",
        "serviceLongArnFormat"
      ], setting.name)
    ])
    error_message = "Setting name must be one of: containerInsights, containerInstanceLongArnFormat, taskLongArnFormat, serviceLongArnFormat."
  }

  validation {
    condition = alltrue([
      for setting in var.settings : setting.name != "containerInsights" || contains(["enhanced", "enabled", "disabled"], setting.value)
    ])
    error_message = "containerInsights setting value must be one of: enhanced, enabled, disabled."
  }

  validation {
    condition = alltrue([
      for setting in var.settings :
      !contains(["containerInstanceLongArnFormat", "taskLongArnFormat", "serviceLongArnFormat"], setting.name) ||
      contains(["enabled", "disabled"], setting.value)
    ])
    error_message = "Long ARN format setting values must be 'enabled' or 'disabled'."
  }
}

# Configuration Block
variable "configuration" {
  description = "Execute command configuration for the cluster"
  type = object({
    execute_command_configuration = optional(object({
      kms_key_id = optional(string)
      logging    = optional(string, "DEFAULT")
      log_configuration = optional(object({
        cloud_watch_encryption_enabled = optional(bool, false)
        cloud_watch_log_group_name     = optional(string)
        s3_bucket_name                 = optional(string)
        s3_bucket_encryption_enabled   = optional(bool, false)
        s3_key_prefix                  = optional(string)
      }))
    }))
    managed_storage_configuration = optional(object({
      fargate_ephemeral_storage_kms_key_id = optional(string)
      kms_key_id                           = string
    }))
  })
  default = null

  validation {
    condition     = var.configuration == null || try(contains(["NONE", "DEFAULT", "OVERRIDE"], var.configuration.execute_command_configuration.logging), true)
    error_message = "Execute command logging must be one of: NONE, DEFAULT, OVERRIDE."
  }

  validation {
    condition = var.configuration == null || var.configuration.managed_storage_configuration == null || can(
      regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.configuration.managed_storage_configuration.kms_key_id)
    )
    error_message = "KMS key ID must be a valid KMS key ARN."
  }
}

# Service Connect Defaults
variable "service_connect_defaults" {
  description = "Default Service Connect namespace"
  type = object({
    namespace = string
  })
  default = null

  validation {
    condition     = var.service_connect_defaults == null || can(regex("^arn:aws:servicediscovery:[a-z0-9-]+:[0-9]{12}:namespace/.+", var.service_connect_defaults.namespace))
    error_message = "Service Connect namespace must be a valid AWS Service Discovery HTTP namespace ARN."
  }
}
