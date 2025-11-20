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

variable "name" {
  description = "Name for the ECS service"
  type        = string
}

variable "desired_count" {
  description = "The number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

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

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-east-2a"
}
