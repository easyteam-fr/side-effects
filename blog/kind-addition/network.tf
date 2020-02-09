data "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
}

resource "random_id" "key" {
  byte_length = 8
}

data "aws_availability_zones" "az" {}

data "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.az.names[0]
}

