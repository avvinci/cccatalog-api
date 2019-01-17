provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket="cccatalog-api"
    key="terraform/prod/terraform_prod.tfstate"
    region="us-east-1"
  }
}

# Variables passed in from the secrets file
variable "redis_password" {
  type = "string"
}
variable "database_password" {
  type = "string"
}
variable "django_secret_key" {
  type = "string"
}
variable "wsgi_auth_credentials" {
  type = "string"
}
variable "aws_access_key_id" {
  type = "string"
}
variable "aws_secret_access_key" {
  type = "string"
}
variable "upstream_db_password" {
  type = "string"
}

module "cacheserver" {
  source         = "../../modules/services/cacheserver"
  redis_password = "${var.redis_password}"
  instance_type  = "t2.small"
  environment    = "prod2"
  vpc_id         = "vpc-b741b4cc"
}

module "cccatalog-api" {
  source = "../../modules/services/cccatalog-api"

  vpc_id                    = "vpc-b741b4cc"
  name_suffix               = "-prod2"
  environment               = "prod2"
  min_size                  = 3
  max_size                  = 3
  instance_type             = "c5d.xlarge"
  enable_monitoring         = false
  git_revision              = "c658551141270261d54d09037bc4079693e298bb"
  api_version               = "0.19.1"

  # Environment-specific variables
  database_host             = "production-api-thumbfix.ctypbfibkuqv.us-east-1.rds.amazonaws.com"
  django_debug_enabled      = "false"
  elasticsearch_port        = "80"
  aws_region                = "us-east-1"
  elasticsearch_url         = "search-cccatalog-es-prod5-thumbfix-cmkzg7lodbsalll7suftj55pv4.us-east-1.es.amazonaws.com"
  redis_host                = "ip-172-30-1-210.ec2.internal"
  ccc_api_host              = "api.creativecommons.engineering"
  root_shortening_url       = "shares.cc"

  # Secrets not checked into version control. Override with -var-file=secrets.tfvars
  database_password         = "${var.database_password}"
  django_secret_key         = "${var.django_secret_key}"
  wsgi_auth_credentials     = "${var.wsgi_auth_credentials}"
  aws_access_key_id         = "${var.aws_access_key_id}"
  aws_secret_access_key     = "${var.aws_secret_access_key}"
  redis_password            = "${var.redis_password}"
}

module "ccsearch" {
  source = "../../modules/services/ccsearch"

  vpc_id                    = "vpc-b741b4cc"
  environment               = "-prod2"
  git_revision              = "e2e46412adf0a622ed805b34dc4a95fa747b2755"
  instance_type             = "t2.small"
  api_url                   = "https://api.creativecommons.engineering"
}

module "ingestion-server" {
  source = "../../modules/services/ingestion-server"

  vpc_id                = "vpc-b741b4cc"
  elasticsearch_url     = "search-cccatalog-es-prod5-thumbfix-cmkzg7lodbsalll7suftj55pv4.us-east-1.es.amazonaws.com"
  elasticsearch_port    = "80"
  database_host         = "production-api-thumbfix.ctypbfibkuqv.us-east-1.rds.amazonaws.com"
  database_port         = "5432"
  database_password     = "${var.database_password}"
  upstream_db_host      = "ccsearch-intermediary-db.ctypbfibkuqv.us-east-1.rds.amazonaws.com"
  upstream_db_password  = "${var.upstream_db_password}"
  aws_access_key_id     = "${var.aws_access_key_id}"
  aws_secret_access_key = "${var.aws_secret_access_key}"
  copy_tables           = "image"
  db_buffer_size        = "200000"
  aws_region            = "us-east-1"
  environment           = "prod2"
  poll_interval         = "60"
  docker_tag            = "0.3"
  instance_type         = "m5.large"
  subdomain             = "prod"
}
