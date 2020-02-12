data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"] # Amazon
}

resource "aws_key_pair" "key" {
  key_name   = "${random_id.key.hex}-key}"
  public_key = var.public_key
}

resource "aws_instance" "public" {
  ami           = data.aws_ami.amazon.id
  instance_type = "m5.large"
  key_name      = aws_key_pair.key.key_name

  vpc_security_group_ids      = [aws_security_group.default.id]
  subnet_id                   = data.aws_subnet.public.id
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }

  user_data = templatefile("${path.module}/bootstrap.tmpl",
                { kind_version = "0.7.0", kubectl_version = "1.17.2", golang_version = "1.13.7", compose_version = "1.25.4" , kustomize_version = "3.5.4"})

  tags = {
    Name = random_id.key.hex
  }
}

output "ssh_access" {
  value = "ssh ec2-user@${aws_instance.public.public_ip}"
}
