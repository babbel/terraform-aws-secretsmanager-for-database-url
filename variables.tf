variable "adopt_current_password" {
  type    = bool
  default = false

  description = <<EOS
Write-only mode only: take the password from the URL already stored in this module's `database_url`
secret instead of `password_wo`. Use it to move an existing secret to write-only without rotating
the database password, and pass the `password_wo` output to the database's write-only password.
EOS

  validation {
    condition     = !var.adopt_current_password || var.secret_string_wo_version != null
    error_message = "adopt_current_password needs secret_string_wo_version."
  }
}

variable "database_name" {
  type = string

  description = <<EOS
Name of the database on to be used in the `DATABASE_URL`.
EOS
}

variable "db_instance" {
  type = object({
    address  = string
    password = string
    username = string
  })
  default = null

  description = <<EOS
Database instance to be used in the `DATABASE_URL`.
EOS
}

variable "default_tags" {
  type    = map(string)
  default = {}

  description = <<EOS
Map of tags assigned to all AWS resources created by this module.
EOS
}

variable "name_prefix" {
  type = string

  description = <<EOS
Name prefix for the SecretsManager. The full name will be $${var.name_prefix}.database_url.
EOS
}

variable "protocol" {
  type = string

  description = <<EOS
Protocol to be used in the `DATABASE_URL`.
EOS
}

variable "rds_cluster" {
  type = object({
    master_username = string
    master_password = string
    endpoint        = string
    reader_endpoint = string
  })
  default = null

  description = <<EOS
Database cluster to be used in the `DATABASE_URL`.
EOS
}

variable "secretsmanager_secret_tags" {
  type    = map(string)
  default = {}

  description = <<EOS
Map of tags assigned to the SecretsManager secret created by this module. Tags in this map will override tags in `var.default_tags`.
EOS
}

variable "password_wo" {
  type      = string
  default   = null
  ephemeral = true

  description = <<EOS
Write-only mode only: the database password, e.g. from an `ephemeral "random_password"`. Ignored
with `adopt_current_password`. Bump `secret_string_wo_version` to write a new value.
EOS
}

variable "secret_string_wo_version" {
  type    = number
  default = null

  description = <<EOS
Turns on write-only mode: both secrets are written with `secret_string_wo`, so neither the URLs nor
the password are stored in the state, and the password in `db_instance` or `rds_cluster` is not
read. Changing the version writes the secrets again.
EOS
}
