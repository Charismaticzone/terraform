resource "aws_db_subnet_group" "main" {
  name       = "v3-rds"
  subnet_ids = aws_subnet.webservers.*.id
  tags = {
    Name = "v3"
  }
}

resource "aws_security_group" "rds" {
  name        = "v3 RDS"
  description = "Security Group for V3 RDS"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "v3_rds"
  }
}

resource "aws_security_group_rule" "main_rds_ingress_mysql" {
  security_group_id = aws_security_group.rds.id
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "main_rds_egress_public" {
  security_group_id = aws_security_group.rds.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_db_parameter_group" "main" {
  name   = "rds-v3"
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }
}

resource "aws_db_instance" "main" {
  identifier                = "v3"
  allocated_storage         = 20
  storage_type              = "gp2"
  engine                    = "mysql"
  engine_version            = "5.7.26"
  instance_class            = "db.t3.micro"
  name                      = "exercism_v3"
  username                  = "exercism_v3"
  password                  = "exercism_v3"
  port                      = 3306
  publicly_accessible       = false
  availability_zone         = "${var.region}a"
  security_group_names      = []
  vpc_security_group_ids    = [aws_security_group.rds.id]
  db_subnet_group_name      = aws_db_subnet_group.main.name
  parameter_group_name      = aws_db_parameter_group.main.name
  multi_az                  = false
  final_snapshot_identifier = "v3-${formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())}"
  enabled_cloudwatch_logs_exports = [
    "error",
    "slowquery",
  ]
  tags = {
    Name = "v3"
  }
}
