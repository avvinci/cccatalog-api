provider "aws" {
  region = "us-east-1"
}

module "ccsearch" {
  source = "../../../../modules/services/ccsearch"

  vpc_id                    = "vpc-b741b4cc"
  environment               = "-prod"
  git_revision              = "90a0cf95c3f7d41c6ebf772791c7026da8edc9e0"
  instance_type             = "t2.small"
  api_url                   = "https://api.creativecommons.engineering"
}
