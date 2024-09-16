resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.eu-west-3.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.sn-public-1.id,
    aws_subnet.sn-public-2.id,
    aws_subnet.sn-public-3.id
  ]
}

resource "aws_internet_gateway" "veille" {
  vpc_id = var.vpc_id
}

resource "aws_route_table" "veille" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.veille.id
  }
}
resource "aws_subnet" "sn-public-1" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.aws_region}a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "sn-public-2" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.aws_region}b"
  cidr_block        = "10.0.2.0/24"
}

resource "aws_subnet" "sn-public-3" {
  vpc_id            = var.vpc_id
  availability_zone = "${var.aws_region}c"
  cidr_block        = "10.0.3.0/24"
}