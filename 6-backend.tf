resource "aws_subnet" "private-app-subnet-1" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-app-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private-app-subnet-2" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-app-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

resource "aws_launch_template" "auto-scaling-group-backend" {
  name_prefix   = "auto-scaling-group-backend"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = "source_key"
  lifecycle {
    create_before_destroy = true
  }
  vpc_security_group_ids = [aws_security_group.ssh-security-group.id]
}

resource "aws_autoscaling_group" "asg-backend" {
  vpc_zone_identifier = [aws_subnet.private-app-subnet-1.id, aws_subnet.private-app-subnet-2.id]
  desired_capacity   = 1
  max_size           = 10
  min_size           = 1

  launch_template {
    id      = aws_launch_template.auto-scaling-group-backend.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.target_group_backend.arn]
}

resource "aws_security_group" "alb_sg" {
  name        = "example-security-group"
  description = "Example Security Group"
  vpc_id      = aws_vpc.vpc_01.id
}

resource "aws_lb" "alb_backend" {
  name               = "alb-backend"
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.private-app-subnet-1.id, aws_subnet.private-app-subnet-2.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "target_group_backend" {
  name     = "tg-backend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_01.id
}

resource "aws_lb_listener" "frontend_http_listener" {
  load_balancer_arn = aws_lb.alb_backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_backend.arn
  }
}
