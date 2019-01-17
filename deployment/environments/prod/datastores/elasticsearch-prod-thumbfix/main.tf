# A temporary cluster for the purpose of reindexing data without downtime.
# Once the data has been reindexed, it will be used as the main cluster.

provider "aws" {
  region = "us-east-1"
}

resource "aws_elasticsearch_domain" "elasticsearch-prod-thumbfix" {
  domain_name           = "cccatalog-es-prod5-thumbfix"
  elasticsearch_version = "6.2"
  cluster_config {
    instance_type            = "m4.4xlarge.elasticsearch"
    dedicated_master_count   = "3"
    dedicated_master_enabled = "true"
    dedicated_master_type    = "m3.medium.elasticsearch"
    instance_count           = "3"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  ebs_options {
    ebs_enabled = true
    volume_type = "gp2"
    volume_size = 700
  }

  access_policies = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::664890800379:user/openledger"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:us-east-1:664890800379:domain/cccatalog-elasticsearch-prod/*"
    }
  ]
}
EOF
}
