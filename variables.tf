variable "aws_region" {
  description = "AWS region"
  type = string
  default = "eu-west-3"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type = map(string)
  default = {
    "Project" = "Veille"
    "Environment" = "Dev"
    "Owner" = "Mathieu Durand"
  }
}

variable "db_username" {
  description = "Database username"
  type = string
}

variable "db_password" {
  description = "Database password"
  type = string
}