resource "aws_secretsmanager_secret" "this" {
  name        = "${var.name_prefix}.database_url"
  description = "Secret value is managed via Terraform"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.arn

  secret_string = "${var.protocol}://${var.db_instance.username}:${var.db_instance.password}@${var.db_instance.address}/${var.database_name}"
}
