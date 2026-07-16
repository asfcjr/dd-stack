resource "aws_dynamodb_table" "this" {
  name         = "state-locking-${data.aws_caller_identity.current.account_id}"
  billing_mode = var.remote_backend.state_locking.dynamodb_table_billing_mode
  hash_key     = var.remote_backend.state_locking.dynamodb_table_hash_key

  attribute {
    name = var.remote_backend.state_locking.dynamodb_table_hash_key
    type = var.remote_backend.state_locking.dynamodb_table_hash_key_type
  }
}
