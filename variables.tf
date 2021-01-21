variable "database_name" {
  type = string

  description = "Name of the database on `var.db_instance` to be used in the `DATABASE_URL`."
}

variable "db_instance" {
  type = object({
    address  = string
    password = string
    username = string
  })

  description = "Database instance to be used in the `DATABASE_URL`."
}

variable "name_prefix" {
  type = string

  description = "Name prefix for the SecretsManager. The full name will be $${var.name_prefix}.database_url."
}

variable "protocol" {
  type = string

  description = "Protocol to be used in the `DATABASE_URL`."
}

variable "tags" {
  type    = map(string)
  default = {}

  description = "Tags which will be assigned to all resources."
}
