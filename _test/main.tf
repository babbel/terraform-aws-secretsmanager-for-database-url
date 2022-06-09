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

  tags = {
    app = "example"
    env = "production"
  }
}
