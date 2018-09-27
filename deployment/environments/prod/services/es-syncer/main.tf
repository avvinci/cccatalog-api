provider "aws" {
  region = "us-east-1"
}

# Variables passed in from the secrets file get declared here.
variable "database_password" {
  type = "string"
}
variable "aws_access_key_id" {
  type = "string"
}
variable "aws_secret_access_key" {
  type = "string"
}

module "es-syncer" {
  source = "../../../../modules/services/es-syncer"

  vpc_id                = "vpc-b741b4cc"
  elasticsearch_url     = "search-cccatalog-es-prod2-v426vgj2ksjet5kettvub3tii4.us-east-1.es.amazonaws.com"
  elasticsearch_port    = "80"
  database_host         = "preprod-10m.ctypbfibkuqv.us-east-1.rds.amazonaws.com"
  database_port         = "5432"
  database_password     = "${var.database_password}"
  aws_access_key_id     = "${var.aws_access_key_id}"
  aws_secret_access_key = "${var.aws_secret_access_key}"
  copy_tables           = "image"
  db_buffer_size        = "100000"
  aws_region            = "us-east-1"
  environment           = "prod"
  poll_interval         = "60"
  docker_tag            = "2.1"
}
