locals {
  username = var.db_instance != null ? var.db_instance.username : var.rds_cluster.master_username
  password = var.db_instance != null ? var.db_instance.password : var.rds_cluster.master_password
  server   = var.db_instance != null ? var.db_instance.address : var.rds_cluster.endpoint
}

resource "aws_secretsmanager_secret" "this" {
  name        = "${var.name_prefix}.database_url"
  description = "Secret value is managed via Terraform"

  tags = merge(var.default_tags, var.secretsmanager_secret_tags)
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.arn

  secret_string = "${var.protocol}://${local.username}:${local.password}@${local.server}/${var.database_name}"
}
