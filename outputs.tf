output "topic-name" {
  value = google_pubsub_topic.firewall-insert-export-topic.name
}

output "project" {
  value = google_pubsub_topic.firewall-insert-export-topic.project
}

output "organization_sink_writer" {
  value       = google_logging_organization_sink.firewall-insert-log-sink.writer_identity
  description = "The Service Account associated with the organization sink.  Ensure this account has publish permissions to a pubsub topic"
}

output "network_name" {
  value = module.vpc.network_name
}
