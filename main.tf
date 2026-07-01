data "aws_subnet" "public" {
  id = "subnet-062f245a4abd51af8"
}

resource "aws_instance" "runner" {
  ami           = local.ami_id
  instance_type = "t3.small"

  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = data.aws_subnet.public.id

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