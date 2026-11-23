locals {
  username        = var.db_instance != null ? var.db_instance.username : var.rds_cluster.master_username
  endpoint        = var.db_instance != null ? var.db_instance.address : var.rds_cluster.endpoint
  reader_endpoint = var.db_instance != null ? var.db_instance.address : var.rds_cluster.reader_endpoint

  write_only = var.secret_string_wo_version != null

  # Only read in plain mode: in write-only mode the password stays out of the state.
  password = local.write_only ? null : (var.db_instance != null ? var.db_instance.password : var.rds_cluster.master_password)
}

resource "aws_secretsmanager_secret" "endpoint" {
  name        = "${var.name_prefix}.database_url"
  description = "Secret value is managed via Terraform"

  tags = merge(var.default_tags, var.secretsmanager_secret_tags)
}

resource "aws_secretsmanager_secret_version" "endpoint" {
  secret_id = aws_secretsmanager_secret.endpoint.arn

  secret_string = local.write_only ? null : "${var.protocol}://${urlencode(local.username)}:${urlencode(local.password)}@${local.endpoint}/${urlencode(var.database_name)}"

  secret_string_wo         = local.write_only ? "${var.protocol}://${urlencode(local.username)}:${urlencode(local.password_wo)}@${local.endpoint}/${urlencode(var.database_name)}" : null
  secret_string_wo_version = var.secret_string_wo_version

  lifecycle {
    precondition {
      condition     = local.password_wo_decoded
      error_message = local.password_wo_decode_error
    }
  }
}

resource "aws_secretsmanager_secret" "reader_endpoint" {
  name        = "${var.name_prefix}.database_replica_url"
  description = "Secret value is managed via Terraform"

  tags = merge(var.default_tags, var.secretsmanager_secret_tags)
}

resource "aws_secretsmanager_secret_version" "reader_endpoint" {
  secret_id = aws_secretsmanager_secret.reader_endpoint.arn

  secret_string = local.write_only ? null : "${var.protocol}://${urlencode(local.username)}:${urlencode(local.password)}@${local.reader_endpoint}/${urlencode(var.database_name)}"

  secret_string_wo         = local.write_only ? "${var.protocol}://${urlencode(local.username)}:${urlencode(local.password_wo)}@${local.reader_endpoint}/${urlencode(var.database_name)}" : null
  secret_string_wo_version = var.secret_string_wo_version

  lifecycle {
    precondition {
      condition     = local.password_wo_decoded
      error_message = local.password_wo_decode_error
    }
  }
}

moved {
  from = aws_secretsmanager_secret.this
  to   = aws_secretsmanager_secret.endpoint
}

moved {
  from = aws_secretsmanager_secret_version.this
  to   = aws_secretsmanager_secret_version.endpoint
}
