variable "db_password" {
  description = "Password for the PostgreSQL RDS database"
  type        = string
  sensitive   = true
}