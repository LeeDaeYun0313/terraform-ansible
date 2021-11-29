
resource "aws_db_instance" "ldy_db" {
  allocated_storage      = var.db_storage
  storage_type           = var.db_storage_type
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instacnce_class
  name                   = var.db_name
  identifier             = var.db_identifier
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = var.db_parameter_group_name
  port                   = var.rds_mysql_port
  availability_zone      = var.db_avazone
  db_subnet_group_name   = aws_db_subnet_group.ldy_db_group.id
  vpc_security_group_ids = [aws_security_group.ldy_dbsg.id]
  skip_final_snapshot    = var.db_snapshot
  tags = {
    name = "${var.name}-mydb"
  }
}


resource "aws_db_subnet_group" "ldy_db_group" {
  name       = "dbgroup"
  subnet_ids = [aws_subnet.ldy_pri_db[0].id,aws_subnet.ldy_pri_db[1].id]
  tags = {
    Name = "dbgroup"
  }
}
