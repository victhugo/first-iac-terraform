variable "instance_type" {
  type = string
  default = "t2.micro"
}

resource "aws_security_group" "vhugo-sg" {
  name = "vhugo-sg"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "vhugo-key" {
  key_name = "vhugo.godinez"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_ami" "amazon-ami-vhugo" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.20190603-x86_64-ebs"]
  }

  owners = ["591542846629"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon-ami-vhugo.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.vhugo-sg.id]

  key_name = aws_key_pair.vhugo-key.key_name

  user_data = file("./user-data.txt")

  tags = {
    Name = "ec2-vhugo-terraform"
  }
}

output "security_group_id" {
  value = aws_security_group.vhugo-sg.id
}

output "instance_ip4" {
  value = aws_instance.web.public_ip
}
