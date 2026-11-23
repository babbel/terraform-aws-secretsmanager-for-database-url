output "secretsmanager_secret" {
  value = aws_secretsmanager_secret.endpoint

  description = "The AWS SecretsManager containing the `DATABASE_URL`."
}

output "secretsmanager_secret_reader_endpoint" {
  value = aws_secretsmanager_secret.reader_endpoint

  description = "The AWS SecretsManager containing the `DATABASE_REPLICA_URL`."
}

output "password_wo" {
  value     = local.write_only ? local.password_wo : null
  ephemeral = true

  precondition {
    condition     = local.password_wo_decoded
    error_message = local.password_wo_decode_error
  }

  description = <<EOS
Write-only mode only: the password written into the URLs. With `adopt_current_password`, pass it
to the database's `master_password_wo` or `password_wo` so the database keeps its password.
EOS
}
