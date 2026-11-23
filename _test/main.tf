provider "aws" {
  region = "locale"
}

module "secretsmanager" {
  source = "./.."

  name_prefix = "example"

  db_instance = {
    address  = "db.example.com"
    username = "root"
    password = "secret"
  }

  database_name = "example"
  protocol      = "mysql2"

  default_tags = {
    app = "example"
    env = "production"
  }
}

ephemeral "random_password" "example" {
  length = 16
}

module "secretsmanager-write-only" {
  source = "./.."

  name_prefix = "example-write-only"

  rds_cluster = {
    master_username = "root"
    master_password = null
    endpoint        = "example.cluster-abc.eu-west-1.rds.amazonaws.com"
    reader_endpoint = "example.cluster-ro-abc.eu-west-1.rds.amazonaws.com"
  }

  database_name = "example"
  protocol      = "mysql2"

  password_wo              = ephemeral.random_password.example.result
  secret_string_wo_version = 1
}

# Moving an existing secret to write-only without rotating the password.
module "secretsmanager-adopted" {
  source = "./.."

  name_prefix = "example-adopted"

  rds_cluster = {
    master_username = "root"
    master_password = null
    endpoint        = "example.cluster-abc.eu-west-1.rds.amazonaws.com"
    reader_endpoint = "example.cluster-ro-abc.eu-west-1.rds.amazonaws.com"
  }

  database_name = "example"
  protocol      = "mysql2"

  adopt_current_password   = true
  secret_string_wo_version = 1
}
