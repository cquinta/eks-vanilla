resource "aws_secretsmanager_secret" "teste-secret" {
  name = "chip-teste1"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "teste-secret" {
  secret_id     = aws_secretsmanager_secret.teste-secret.id
  secret_string = "BAR"
}

resource "aws_secretsmanager_secret" "teste_json" {
  name = "chip-teste-json1"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "teste_json" {
  secret_id     = aws_secretsmanager_secret.teste_json.id
  secret_string = jsonencode({
    foo = "BAR",
    username = "admin",
    password = "abc123"
  })
}