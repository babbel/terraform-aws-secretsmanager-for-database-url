# Write-only mode (var.secret_string_wo_version set): the password never enters the state.
# It comes from var.password_wo, or, with var.adopt_current_password, from the URL already in
# this module's database_url secret, so an existing secret can move to write-only without
# rotating the database password.

ephemeral "aws_secretsmanager_secret_version" "endpoint_current" {
  count = var.adopt_current_password ? 1 : 0

  secret_id = aws_secretsmanager_secret.endpoint.arn
}

locals {
  # The password as urlencode() wrote it into the URL: between "user:" and "@".
  current_password_encoded = var.adopt_current_password ? regex("^[^:]+://[^:@/]*:([^@]*)@", ephemeral.aws_secretsmanager_secret_version.endpoint_current[0].secret_string)[0] : null

  # Terraform has no urldecode(). urlencode() keeps letters, digits and "-._~", writes a space
  # as "+" and escapes the rest as %XX, so undo that for the printable ASCII characters: "+"
  # first, before "%2B" turns into "+", and "%25" last, so that an escaped "%" is not decoded
  # twice. The precondition on the endpoint secret checks that the result encodes back to the
  # same text, so a wrong decode fails the plan instead of changing the password.
  current_password = var.adopt_current_password ? replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
    replace(local.current_password_encoded, "+", " "),
    "%20", " "), "%21", "!"), "%22", "\""), "%23", "#"), "%24", "$"), "%26", "&"), "%27", "'"), "%28", "("),
    "%29", ")"), "%2A", "*"), "%2B", "+"), "%2C", ","), "%2F", "/"), "%3A", ":"), "%3B", ";"), "%3C", "<"),
    "%3D", "="), "%3E", ">"), "%3F", "?"), "%40", "@"), "%5B", "["), "%5C", "\\"), "%5D", "]"), "%5E", "^"),
  "%60", "`"), "%7B", "{"), "%7C", "|"), "%7D", "}"), "%25", "%") : null

  password_wo = var.adopt_current_password ? local.current_password : var.password_wo
}
