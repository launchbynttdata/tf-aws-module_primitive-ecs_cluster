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

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "The IDs of the subnets"
  value       = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.this.id
}

output "ecs_service_id" {
  description = "The ID of the ECS service"
  value       = module.ecs_service.id
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.ecs_service.name
}

output "ecs_service_cluster" {
  description = "The cluster the ECS service is associated with"
  value       = module.ecs_service.cluster
}

output "ecs_service_desired_count" {
  description = "The desired number of tasks for the ECS service"
  value       = module.ecs_service.desired_count
}

output "ecs_service_task_definition" {
  description = "The task definition ARN used by the ECS service"
  value       = module.ecs_service.task_definition
}

output "ecs_service_launch_type" {
  description = "The launch type of the ECS service"
  value       = module.ecs_service.launch_type
}
