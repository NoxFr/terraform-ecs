resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_service" "service" {
  name                = var.ecs_service_name
  cluster             = aws_ecs_cluster.cluster.id
  task_definition     = aws_ecs_task_definition.service.arn
  scheduling_strategy = "REPLICA"
  desired_count       = 2
  launch_type         = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets          = var.vpc_subnets
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg-ecs.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.https_forward,
    aws_iam_role_policy_attachment.ecs_task_execution_role
  ]
}

resource "aws_ecs_task_definition" "service" {
  family             = var.ecs_task_family
  network_mode       = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                = 256
  memory             = 512
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = var.container_name
      image = var.docker_image,
      repositoryCredentials = {
        credentialsParameter = var.docker_registry_secret_arn
      }
      environment = [var.extra_environment]
      portMappings = [
        {
          containerPort = var.container_port,
          hostPort      = var.container_port
        }
      ]
    }
  ])
}


resource "aws_lb" "lb-ecs" {
  name               = "${var.ecs_service_name}-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.loadbalancer.id]
  subnets            = var.vpc_subnets
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.lb-ecs.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-ecs.arn
  }
}

resource "aws_lb_target_group" "tg-ecs" {
  name        = "${var.ecs_service_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "90"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "20"
    path                = "/"
    unhealthy_threshold = "2"
  }
}
