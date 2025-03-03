# Output the RDS endpoint
output "rds_endpoint" {
  value = aws_db_instance.nonso_db.endpoint
}