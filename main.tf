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
# ECS CLUSTER PRIMITIVE MODULE
# =======================================================================
# This module creates a single aws_ecs_cluster resource with comprehensive
# configuration options for cluster settings, execute command configuration,
# service connect defaults, and monitoring.
# =======================================================================

# Main ECS Cluster Resource
resource "aws_ecs_cluster" "this" {
  name = var.name

  # Settings Configuration (conditional)
  dynamic "setting" {
    for_each = var.settings
    content {
      name  = setting.value.name
      value = setting.value.value
    }
  }

  # Configuration Block (conditional)
  dynamic "configuration" {
    for_each = var.configuration != null ? [var.configuration] : []
    content {
      # Execute Command Configuration (conditional)
      dynamic "execute_command_configuration" {
        for_each = configuration.value.execute_command_configuration != null ? [configuration.value.execute_command_configuration] : []
        content {
          kms_key_id = execute_command_configuration.value.kms_key_id
          logging    = execute_command_configuration.value.logging

          # Log Configuration (conditional)
          dynamic "log_configuration" {
            for_each = execute_command_configuration.value.log_configuration != null ? [execute_command_configuration.value.log_configuration] : []
            content {
              cloud_watch_encryption_enabled = log_configuration.value.cloud_watch_encryption_enabled
              cloud_watch_log_group_name     = log_configuration.value.cloud_watch_log_group_name
              s3_bucket_name                 = log_configuration.value.s3_bucket_name
              s3_bucket_encryption_enabled   = log_configuration.value.s3_bucket_encryption_enabled
              s3_key_prefix                  = log_configuration.value.s3_key_prefix
            }
          }
        }
      }

      # Managed Storage Configuration (conditional)
      dynamic "managed_storage_configuration" {
        for_each = configuration.value.managed_storage_configuration != null ? [configuration.value.managed_storage_configuration] : []
        content {
          kms_key_id                           = managed_storage_configuration.value.kms_key_id
          fargate_ephemeral_storage_kms_key_id = lookup(managed_storage_configuration.value, "fargate_ephemeral_storage_kms_key_id", null)
        }
      }
    }
  }

  # Service Connect Defaults (conditional)
  dynamic "service_connect_defaults" {
    for_each = var.service_connect_defaults != null ? [var.service_connect_defaults] : []
    content {
      namespace = service_connect_defaults.value.namespace
    }
  }

  # Tags
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
