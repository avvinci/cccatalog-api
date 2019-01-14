output "ec2-instance-url" {
  value = "${module.cacheserver.ec2-instance-url}"
}

output "load-balancer-url" {
  value = "${module.cccatalog-api.load-balancer-url}"
}

output "autoscaling-group-name" {
  value = "${module.cccatalog-api.autoscaling-group-name}"
}

