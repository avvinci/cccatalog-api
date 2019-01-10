output "cache-url" {
  value = "${module.cacheserver.ec2-instance-url}"
}

/* This is defined in the branch elasticsearch_auto_reindex, which needs to be merged.
output "ingestion-url" {
  value = "${module.ingestion-server.ec2-instance-url}"
}
*/