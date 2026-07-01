data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0618f6141d79da029"]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

locals {
  public_subnet_id = element(data.aws_subnets.public.ids, 0)
}

resource "aws_instance" "runner" {
  ami           = local.ami_id
  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = local.public_subnet_id

  root_block_device {
    volume_size = 50
    volume_type = "gp3"
  }

  user_data = file("runner.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-runner"
    }
  )
}

resource "aws_security_group" "main" {
  name        = "${var.project}-${var.environment}-runner"
  description = "Created to attach runner"
  vpc_id      = "vpc-0618f6141d79da029"

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

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-jenkins"
    }
  )
}