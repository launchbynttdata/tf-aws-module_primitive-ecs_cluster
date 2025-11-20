locals {
  network_configuration = {
    subnets          = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = false
  }
}
