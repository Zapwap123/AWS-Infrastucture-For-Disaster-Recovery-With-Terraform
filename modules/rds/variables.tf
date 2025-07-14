variable "db_instance_id" {
  type = string
}

variable "source_db_identifier" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}
