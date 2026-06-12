resource "aws_db_subnet_group" "postgres" {
  name = "rails-store-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_app_1.id,
    aws_subnet.private_app_2.id
  ]

  tags = {
    Name = "rails-store-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "rails-store-db"

  engine         = "postgres"
  engine_version = "15"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  publicly_accessible = false

  multi_az = false

  storage_encrypted = true

  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  tags = {
    Name = "rails-store-db"
  }
}