# #The password below is injected here from a file for speed and as this is testing, usernames / passwords should never be in your TF files, and should live in a proper secret vault.
# #For this to work properly the .credentials file needs to be in the same directory as this file.

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                 = 1
  identifier            = "${local.rds_instance_name}${count.index}"
  cluster_identifier    = aws_rds_cluster.cardinal-psql-rds-cluster.id
  instance_class        = var.rds_instance_size
  engine                = aws_rds_cluster.cardinal-psql-rds-cluster.engine
  engine_version        = aws_rds_cluster.cardinal-psql-rds-cluster.engine_version
  db_subnet_group_name  = aws_db_subnet_group.cardinal-rds-sub-grp.name
  tags                  = local.default-tags 
}

resource "aws_rds_cluster" "cardinal-psql-rds-cluster" {
  cluster_identifier      = "${local.rds_instance_name}-cluster"
  availability_zones      = ["${var.aws_region}${element(var.aws_azs, 0)}", "${var.aws_region}${element(var.aws_azs, 1)}"]
  database_name           = local.rds_instance_name
  master_username         = var.rds_instance_username
  master_password         = file(".credentials")
  engine                  = var.rds_engine_type
  engine_version          = var.rds_engine_version
  db_subnet_group_name    = aws_db_subnet_group.cardinal-rds-sub-grp.name
  vpc_security_group_ids  = [aws_security_group.cardinal-rds-sg.id]
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 0
  tags                    = local.default-tags 
}