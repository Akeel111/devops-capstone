# -------------------------
# Second Private Subnet
# Required for RDS subnet group
# -------------------------

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "af-south-1a"

  tags = {
    Name = "devops-capstone-private-subnet-2"
  }
}

# -------------------------
# RDS Security Group
# -------------------------

resource "aws_security_group" "db_sg" {
  name        = "devops-capstone-db-sg"
  description = "Allow PostgreSQL access from EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-capstone-db-sg"
  }
}

# -------------------------
# RDS Subnet Group
# -------------------------

resource "aws_db_subnet_group" "main" {
  name = "devops-capstone-db-subnet-group"

  subnet_ids = [
    aws_subnet.private.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "devops-capstone-db-subnet-group"
  }
}

# -------------------------
# PostgreSQL RDS
# -------------------------

resource "aws_db_instance" "postgres" {
  identifier = "devops-capstone-postgres"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "capstone_db"
  username = "capstone_user"
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false
  multi_az            = false

  tags = {
    Name = "devops-capstone-postgres"
  }
}