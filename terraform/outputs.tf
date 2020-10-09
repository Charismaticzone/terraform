output "alb_hostname" {
  value = aws_alb.webservers.dns_name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "rds_cluster_master_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "rds_cluster_reader_endpoint" {
  value = aws_rds_cluster.main.reader_endpoint
}

output "webservers_alb_dns_name" {
  value = aws_alb.webservers.dns_name
}

output "anycable_redis_url" {
  value = aws_elasticache_cluster.anycable.cache_nodes.0.address
}
