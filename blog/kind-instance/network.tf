data "aws_vpc" "default" {
  default = true
}

resource "random_id" "key" {
  byte_length = 8
}

data "aws_availability_zones" "az" {}

data "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.default.id
  availability_zone       = data.aws_availability_zones.az.names[0]
}

resource "aws_security_group" "default" {
  name        = "${random_id.key.hex}-default-sg"
  description = "Used in the terraform"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

