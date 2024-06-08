provider "aws" {
  region = "ap-south-1"
}

resource "aws_ecs_cluster" "hello_world_cluster" {
  name = "hello-world-cluster"
}

resource "aws_ecs_task_definition" "hello_world_task" {
  family                   = "hello-world-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name      = "hello-world-container"
    image     = "harishwin007/hello-world-app"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
  }])
}

resource "aws_ecs_service" "hello_world_service" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.hello_world_cluster.id
  task_definition = aws_ecs_task_definition.hello_world_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-0dd51e6229ec798a6", "subnet-06684c175ef9add6a"]
    security_groups = ["sg-0ccd88942ee4664d5"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_world_tg.arn
    container_name   = "hello-world-container"
    container_port   = 3000
  }
}

resource "aws_lb" "hello_world_lb" {
  name               = "hello-world-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0ccd88942ee4664d5"]
  subnets            = ["subnet-0dd51e6229ec798a6", "subnet-06684c175ef9add6a"]
}

resource "aws_lb_target_group" "hello_world_tg" {
  name     = "hello-world-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "vpc-0c3f56947af63aeec"
  target_type = "ip"  # or "ip_port"
}

resource "aws_lb_listener" "hello_world_listener" {
  load_balancer_arn = aws_lb.hello_world_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hello_world_tg.arn
  }
}

