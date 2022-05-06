resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "16dbcredentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
{
  "username": "${aws_db_instance.mydb.username}",
  "password": "${random_password.master_password.result}",
  "engine": "mysql",
  "host": "${aws_db_instance.mydb.endpoint}",
  "port": ${aws_db_instance.mydb.port},
  "identifier": "${aws_db_instance.mydb.identifier}"
}
EOF
}

resource "aws_db_instance" "mydb" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = "root"
  password               = random_password.master_password.result
  parameter_group_name   = aws_db_parameter_group.default.name
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
  vpc_security_group_ids = [ module.eks.worker_security_group_id ] 
}

resource "aws_db_subnet_group" "db-subnet" {
  name       = "dbsubnets"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_parameter_group" "default" {
  family = "mysql5.7"
  parameter {
    name  = "max_connections"
    value = "1337"
  }
}
