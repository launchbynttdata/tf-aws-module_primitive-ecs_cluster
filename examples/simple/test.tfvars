settings = [
  {
    name  = "containerInsights"
    value = "enabled"
  }
]

tags = {
  Environment = "example"
  Project     = "ecs-cluster"
}

logical_product_family  = "demo"
logical_product_service = "ecs"
region                  = "us-east-1"
class_env               = "test"
cloud_resource_type     = "ecs"
