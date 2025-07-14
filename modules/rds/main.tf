terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_instance_id}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.db_instance_id}-subnet-group"
  }
}

resource "aws_db_instance" "replica" {
  identifier           = var.db_instance_id
  replicate_source_db  = var.source_db_identifier
  instance_class       = var.instance_class
  publicly_accessible  = false
  skip_final_snapshot  = true
  apply_immediately    = true
  availability_zone    = var.azs[0]
  db_subnet_group_name = aws_db_subnet_group.this.name

  tags = {
    Name = "${var.db_instance_id}"
  }
}
