# SecretsManager for `DATABASE_URL`

This module creates a SecretsManager and stores the [`DATABASE_URL`](https://guides.rubyonrails.org/configuring.html#configuring-a-database) for the given `aws_db_instance` or `aws_rds_cluster` in it.

This is useful in order to load the `DATABASE_URL` into ECS via [`containerDefinitions.secrets.valueFrom`](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data-secrets.html).

## Usage

```tf
module "secretsmanager-for-database-url" {
  source  = "babbel/secretsmanager-for-database-url/aws"
  version = "~> 1.2"

  name_prefix = "example"

  db_instance   = aws_db_instance.example
  database_name = "example"
  protocol      = "mysql2"

  tags = {
    app = "example"
    env = "production"
  }
}
```

It can also be used for an RDS cluster like this:

```tf
module "secretsmanager-for-database-url" {
  source  = "babbel/secretsmanager-for-database-url/aws"
  version = "~> 1.2"

  name_prefix = "example"

  rds_cluster   = aws_rds_cluster.example
  database_name = "example"
  protocol      = "mysql2"

  tags = {
    app = "example"
    env = "production"
  }
}
```

In the ECS task definition, you can now define environment variables referencing the SecretsManager:

```tf
resource "aws_ecs_task_definition" "example" {
  ...

  container_definitions = jsonencode([{
    ...

    secrets = [{
      name  = "DATABASE_URL"
      value = module.secretsmanager-for-database-url.secretsmanager_secret.arn
    }]

    ...
  }])

  ...
}
```

Please also make sure that you grant permissions on the `secretsmanager:GetSecretValue` action for the SecretsManager on the [ECS task execution IAM role](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html).
