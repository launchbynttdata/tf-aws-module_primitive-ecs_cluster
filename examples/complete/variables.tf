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

variable "resource_name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "sgir-complete"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_cidr_ipv4" {
  description = "IPv4 CIDR block allowed for SSH access"
  type        = string
  default     = "10.0.1.0/24"
}

variable "https_cidr_ipv4" {
  description = "IPv4 CIDR block allowed for HTTPS access"
  type        = string
  default     = "10.0.2.0/24"
}

variable "custom_cidr_ipv4" {
  description = "IPv4 CIDR block allowed for custom port range"
  type        = string
  default     = "10.0.3.0/24"
}
