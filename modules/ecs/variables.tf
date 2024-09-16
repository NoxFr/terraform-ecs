variable "aws_region" {
  description = "AWS region"
  type = string
  default = "eu-west-3"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type = string
}

variable "docker_image" {
  description = "Docker image to run"
  type = string
}

variable "docker_registry_secret_arn" {
  description = "Docker registry secret ARN"
  type = string
}

variable "container_port" {
  description = "Container port"
  type = number
  default = 80
}

variable "container_name" {
  description = "Container name"
  type = string
}

variable "ecs_task_family" {
  description = "ECS task family"
  type = string
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
}

variable "extra_environment" {
  description = "Extra environment variables"
  type = map(string)
  default = {}
}