# SecretsManager for `DATABASE_URL`

This module creates a SecretsManager and stores the [`DATABASE_URL`](https://guides.rubyonrails.org/configuring.html#configuring-a-database) for the given `aws_db_instance` or `aws_rds_cluster` in it.

This is useful in order to load the `DATABASE_URL` into ECS via [`containerDefinitions.secrets.valueFrom`](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-secrets.html).

## Usage

```tf
module "secretsmanager-for-database-url" {
  source  = "babbel/secretsmanager-for-database-url/aws"
  version = "~> 3.0"

  name_prefix = "example"

  db_instance   = aws_db_instance.example
  database_name = "example"
  protocol      = "mysql2"
}
```

It can also be used for an RDS cluster like this:

```tf
module "secretsmanager-for-database-url" {
  source  = "babbel/secretsmanager-for-database-url/aws"
  version = "~> 3.0"

  name_prefix = "example"

  rds_cluster   = aws_rds_cluster.example
  database_name = "example"
  protocol      = "mysql2"
}
```

## Keeping the password out of the Terraform state

Set `secret_string_wo_version` to write both secrets with the provider's write-only `secret_string_wo`: neither the URLs nor the password are stored in the state, and the password in `db_instance` or `rds_cluster` is not read. This needs Terraform 1.11 or later.

A new database takes its password from an ephemeral resource, written to the database and the URLs alike:

```tf
ephemeral "random_password" "example" {
  length = 16
}

resource "aws_rds_cluster" "example" {
  ...

  master_password_wo         = ephemeral.random_password.example.result
  master_password_wo_version = 1
}

module "secretsmanager-for-database-url" {
  source  = "babbel/secretsmanager-for-database-url/aws"
  version = "~> 3.0"

  name_prefix = "example"

  rds_cluster   = aws_rds_cluster.example
  database_name = "example"
  protocol      = "mysql2"

  password_wo              = ephemeral.random_password.example.result
  secret_string_wo_version = 1
}
```

To rotate, bump both versions together.

An existing database keeps its password with `adopt_current_password`: the module reads the password from the URL already in its `database_url` secret and returns it as the ephemeral `password_wo` output, to pass on to the database. Nothing rotates. The plan fails if the password cannot be decoded exactly.

```tf
resource "aws_rds_cluster" "example" {
  ...

  master_password_wo         = module.secretsmanager-for-database-url.password_wo
  master_password_wo_version = 1
}

module "secretsmanager-for-database-url" {
  ...

  adopt_current_password   = true
  secret_string_wo_version = 1
}

removed {
  from = random_password.example

  lifecycle {
    destroy = false
  }
}
```

In the ECS task definition, you can now define environment variables referencing the SecretsManager:

```tf
resource "aws_ecs_task_definition" "example" {
  ...

  container_definitions = jsonencode([{
    ...

    secrets = [
    {
      name  = "DATABASE_URL"
      value = module.secretsmanager-for-database-url.secretsmanager_secret.arn
    },
    {
      name  = "DATABASE_REPLICA_URL"
      value = module.secretsmanager-for-database-url.secretsmanager_secret_reader_endpoint.arn
    }
    ]

    ...
  }])

  ...
}
```

Please also make sure that you grant permissions on the `secretsmanager:GetSecretValue` action for the SecretsManager on the [ECS task execution IAM role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html).
