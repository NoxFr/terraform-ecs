provider "aws" {
  region  = var.aws_region
}

resource "aws_vpc" "veille" {
  cidr_block = "10.0.0.0/16"
}

module "ecs" {
  source = "./modules/ecs"
  aws_region  = var.aws_region

  vpc_id = aws_vpc.veille.id

  ecs_cluster_name = "test-cluster"
  ecs_service_name = "veille"
  ecs_task_family = "planka"

  docker_image = "ghcr.io/plankanban/planka:1.21.1"
  docker_registry_secret_arn = "arn:aws:secretsmanager:eu-west-3:746757319801:secret:Github-4GACmG"
  container_port = 1337
  container_name = "planka"
  extra_environment = {
    "DATABASE_URL" = "postgresql://${aws_db_instance.planka-db.username}:${aws_db_instance.planka-db.password}@${aws_db_instance.planka-db.address}:${aws_db_instance.planka-db.port}/planka"
  }
}

resource "aws_db_instance" "planka-db" {
  identifier = "planka-db"
  allocated_storage    = 10
  db_name              = "planka"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
}