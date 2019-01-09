output "cache-url" {
  value = "${module.cacheserver.ec2-instance-url}"
}

/* This is defined in the branch elasticsearch_auto_reindex.
output "ingestion-url" {
  value = "${module.ingestion-server.ec2-instance-url}"
}
*/