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

# Create a VPC for testing
resource "aws_vpc" "test" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.resource_name_prefix}-vpc"
  }
}

# Configure the default security group to deny all traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.test.id

  # No ingress or egress rules = deny all traffic
  tags = {
    Name = "${var.resource_name_prefix}-default-sg"
  }
}

# Create a security group for testing
resource "aws_security_group" "test" {
  name        = "${var.resource_name_prefix}-sg"
  description = "Test security group for ingress rule module"
  vpc_id      = aws_vpc.test.id

  tags = {
    Name = "${var.resource_name_prefix}-sg"
  }
}

# Example 1: SSH access from specific IPv4 CIDR
module "ingress_ssh_ipv4" {
  source = "../../"

  security_group_id = aws_security_group.test.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.ssh_cidr_ipv4
  description       = "Allow SSH from specific IPv4 CIDR"
}

# Example 2: HTTPS access from specific IPv4 CIDR
module "ingress_https_ipv4" {
  source = "../../"

  security_group_id = aws_security_group.test.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = var.https_cidr_ipv4
  description       = "Allow HTTPS from specific IPv4 CIDR"
}

# Example 3: Custom port range
module "ingress_custom_range" {
  source = "../../"

  security_group_id = aws_security_group.test.id
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8090
  cidr_ipv4         = var.custom_cidr_ipv4
  description       = "Allow custom port range"
}
