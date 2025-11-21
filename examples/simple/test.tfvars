name = "my-ecs-cluster"

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
