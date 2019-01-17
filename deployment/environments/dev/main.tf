provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket="cccatalog-api"
    key="terraform/dev/terraform_dev.tfstate"
    region="us-east-1"
  }
}

# Variables passed in from the secrets file get declared here.
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
variable "upstream_db_password"{
  type = "string"
}


module "cacheserver" {
  source         = "../../modules/services/cacheserver"
  redis_password = "${var.redis_password}"
  instance_type  = "t2.small"
  environment    = "dev"
  vpc_id         = "vpc-b741b4cc"
}

module "ccsearch" {
  source = "../../modules/services/ccsearch"

  vpc_id                    = "vpc-b741b4cc"
  environment               = "-dev"
  git_revision              = "e2e46412adf0a622ed805b34dc4a95fa747b2755"
  instance_type             = "t2.small"
  api_url                   = "https://api-dev.creativecommons.engineering"
}

module "cccatalog-api" {
  source = "../../modules/services/cccatalog-api"

  vpc_id                    = "vpc-b741b4cc"
  name_suffix               = ""
  environment               = "dev"
  min_size                  = 1
  max_size                  = 1
  instance_type             = "t2.small"
  enable_monitoring         = false
  git_revision              = "280cbed57d7f26ffa3f999545b142b13b7e0913f"
  api_version               = "0.19.1"

  # Environment-specific variables
  database_host             = "openledger-db-dev3-nvirginia.ctypbfibkuqv.us-east-1.rds.amazonaws.com"
  django_debug_enabled      = "False"
  elasticsearch_port        = "80"
  aws_region                = "us-east-1"
  elasticsearch_url         = "search-cccatalog-elasticsearch-vtptjrgtluyamznw6s4kkdtqju.us-east-1.es.amazonaws.com"
  redis_host                = "ip-172-30-1-215.ec2.internal"
  ccc_api_host              = "api-dev.creativecommons.engineering"
  root_shortening_url       = "dev.shares.cc"
  disable_global_throttling = "True"

  database_password         = "${var.database_password}"
  django_secret_key         = "${var.django_secret_key}"
  wsgi_auth_credentials     = "${var.wsgi_auth_credentials}"
  aws_access_key_id         = "${var.aws_access_key_id}"
  aws_secret_access_key     = "${var.aws_secret_access_key}"
  redis_password            = "${var.redis_password}"
}

module "ingestion-server" {
  source = "../../modules/services/ingestion-server"

  vpc_id                = "vpc-b741b4cc"
  elasticsearch_url     = "search-elasticsearch-ingestion-test-xfyffs6t6udfyr4myjrctpfo6u.us-east-1.es.amazonaws.com"
  elasticsearch_port    = "80"
  database_host         = "temp-ingestion-testing.ctypbfibkuqv.us-east-1.rds.amazonaws.com"
  database_port         = "5432"
  database_password     = "${var.database_password}"
  upstream_db_host      = "ccsearch-intermediary-db.ctypbfibkuqv.us-east-1.rds.amazonaws.com"
  upstream_db_password  = "${var.upstream_db_password}"
  aws_access_key_id     = "${var.aws_access_key_id}"
  aws_secret_access_key = "${var.aws_secret_access_key}"
  copy_tables           = "image"
  db_buffer_size        = "200000"
  aws_region            = "us-east-1"
  environment           = "dev"
  poll_interval         = "60"
  docker_tag            = "0.3"
  instance_type         = "m5.large"
  subdomain             = "dev"
}
