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

variable "settings" {
  description = "Settings for the ECS cluster"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Tags for the ECS cluster"
  type        = map(string)
  default     = {}
}

variable "logical_product_family" {
  description = "Logical product family"
  type        = string
  default     = "demo"
}

variable "logical_product_service" {
  description = "Logical product service"
  type        = string
  default     = "ecs"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "class_env" {
  description = "Class environment"
  type        = string
  default     = "dev"
}

variable "cloud_resource_type" {
  description = "Cloud resource type"
  type        = string
  default     = "ecs"
}
