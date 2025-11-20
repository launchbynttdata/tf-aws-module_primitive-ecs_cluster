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
# ECS SERVICE PRIMITIVE MODULE - DATA SOURCES
# =======================================================================
# This file contains data sources for the ECS service primitive module.
# =======================================================================

# Data source to look up Service Connect services
# This can be used to find the Service Discovery service ARN created by Service Connect
# when service_connect_configuration is enabled with a service
data "aws_service_discovery_service" "service_connect" {
  count = local.service_connect_service_configured && var.service_connect_discovery_name != null ? 1 : 0

  name         = var.service_connect_discovery_name
  namespace_id = var.service_connect_namespace_id

  # Add dependency to ensure the ECS service is created first
  depends_on = [aws_ecs_service.this]
}
