provider "aws" {
  region = "us-east-1"
}

# Variables passed in from the secrets file get declared here.
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

module "cccatalog-api" {
  source = "../../../../modules/services/cccatalog-api"

  vpc_id                    = "vpc-b741b4cc"
  environment               = "dev"
  min_size                  = 2
  max_size                  = 5
  instance_type             = "t2.micro"
  enable_monitoring         = false
  git_revision              = "a39ccc148166c2a6265381a346063d2c594b248b"

  # Environment-specific variables
  database_host             = "openledger-db-dev3-nvirginia.ctypbfibkuqv.us-east-1.rds.amazonaws.com"
  django_debug_enabled      = "false"

  # Secrets not checked into version control. Override with -var-file=secrets.tfvars
  database_password         = "${var.database_password}"
  django_secret_key         = "${var.django_secret_key}"
  wsgi_auth_credentials     = "${var.wsgi_auth_credentials}"
  aws_access_key_id         = "${var.aws_access_key_id}"
  aws_secret_access_key     = "${var.aws_secret_access_key}"
  elasticsearch_port        = "80"
  aws_region                = "us-east-1"
  elasticsearch_url         = "search-cccatalog-elasticsearch-vtptjrgtluyamznw6s4kkdtqju.us-east-1.es.amazonaws.com"
}
