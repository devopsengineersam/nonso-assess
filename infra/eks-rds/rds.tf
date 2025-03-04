resource "aws_db_instance" "nonso_db" {
  identifier           = "nonso-db"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  username             = "admin"
  password             = "yourpassword" # Replace with a secure password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.nonso_subnet_group.name
}

resource "aws_db_subnet_group" "nonso_subnet_group" {
  name       = "nonso-subnet-group"
  subnet_ids = data.aws_subnets.private_subnets.ids # Replace with your EKS cluster's private subnets
}

resource "aws_security_group" "rds_sg" {
  name        = "nonso-rds-sg"
  description = "Allow inbound traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [ "10.0.0.0/16" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Run the SQL script after RDS is created
resource "null_resource" "initialize_database" {
  depends_on = [aws_db_instance.nonso_db]

  provisioner "local-exec" {
    command = <<-EOT
      mysql \
        --host=${aws_db_instance.nonso_db.endpoint} \
        --user=${aws_db_instance.nonso_db.username} \
        --password=${aws_db_instance.nonso_db.password} \
        < ./db/init.sql
    EOT
  }
}

