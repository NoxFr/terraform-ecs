provider "aws" {
  region  = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0"
  name = "veille"

  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  create_database_subnet_group = true
  create_database_subnet_route_table = true
  create_igw = true

  enable_dns_hostnames = true
  public_subnet_tags = {
    Subnet = "public"
  }
  private_subnet_tags = {
    Subnet = "private"
  }
  database_subnet_tags = {
    Subnet = "database"
  }
}
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-west-3.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = module.vpc.public_subnets
}

module "ecs" {
  source = "./modules/ecs"
  aws_region  = var.aws_region

  vpc_id = module.vpc.vpc_id
  vpc_subnets = [module.vpc.public_subnets[0], module.vpc.public_subnets[1], module.vpc.public_subnets[2]]
  vpc_igw = module.vpc.igw_id

  ecs_cluster_name = "test-cluster"
  ecs_service_name = "veille"
  ecs_task_family = "planka"

  docker_image = "ghcr.io/plankanban/planka:1.21.1"
  docker_registry_secret_arn = "arn:aws:secretsmanager:${var.aws_region}:746757319801:secret:Github-4GACmG"
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
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = false
  final_snapshot_identifier = "planka-db-final-snapshot"
  db_subnet_group_name = module.vpc.database_subnet_group_name
}