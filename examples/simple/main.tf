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
  cidr_block = var.vpc_cidr

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
  description = "Simple test security group"
  vpc_id      = aws_vpc.test.id

  tags = {
    Name = "${var.resource_name_prefix}-sg"
  }
}

# Simple SSH ingress rule from IPv4 CIDR
module "ingress_ssh" {
  source = "../../"

  security_group_id = aws_security_group.test.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.cidr_ipv4
  description       = "Allow SSH from specified CIDR"
}
