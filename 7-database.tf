

resource "aws_subnet" "private-db-subnet-1" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-db-subnet-1-cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private-db-subnet-2" {
  vpc_id                  = aws_vpc.vpc_01.id
  cidr_block              = var.private-db-subnet-2-cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

resource "aws_db_subnet_group" "database-subnet-group" {
  name        = "database subnets"
  subnet_ids  = [aws_subnet.private-db-subnet-1.id, aws_subnet.private-db-subnet-2.id]
  description = "Subnet group for database instance"
}

resource "aws_security_group" "database-security-group" {
  name        = "Database server Security Group"
  description = "Enable MYSQL access on port 3306"
  vpc_id      = aws_vpc.vpc_01.id

  ingress {
    description     = "MYSQL access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.webserver-security-group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%+-.=?^{}"
}

resource "aws_kms_key" "rds_key" {
  description             = "KMS key for encrypting RDS instance"
  deletion_window_in_days = 10
}

resource "aws_db_instance" "database-instance" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.database-instance-class
  db_name                = "appdb"
  username               = "lsoica"
  password                = random_password.password.result
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = false
  final_snapshot_identifier = "db-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"
  db_subnet_group_name   = aws_db_subnet_group.database-subnet-group.name
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.database-security-group.id]
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds_key.arn
}