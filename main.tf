data "google_client_config" "current" {}

provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
}

provider "google-beta" {
  project     = "${var.project}"
  region      = "${var.region}"
}

provider "archive" {
  version = "1.1"
}
resource "google_logging_organization_sink" "firewall-insert-log-sink" {
    name             = "${var.org_id}-firewall-insert-log-sink"
    org_id           = "${var.org_id}"
    destination      = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.firewall-insert-export-topic.name}"
    filter           = "${var.org_sink_filter}"
    include_children = true
}

resource "random_id" "sa-id" {
  byte_length = 4
}

resource "google_pubsub_topic" "firewall-insert-export-topic" {
  name        = "firewall-insert-export-topic"
  project     = "${var.project}"
}

resource "google_pubsub_topic_iam_member" "publisher" {
  project = "${var.project}"
  topic   = "${google_pubsub_topic.firewall-insert-export-topic.name}"
  role    = "roles/pubsub.publisher"
  member  = "${google_logging_organization_sink.firewall-insert-log-sink.writer_identity}"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/firewall-remediate-cloudfunction"
  output_path = "${path.module}/firewall-remediate.zip"
}

resource "google_storage_bucket" "bucket" {
  provider = "google"
  project  = "${var.project}"
  name     = "${var.name}-firewall-insert-cf"
}

resource "google_storage_bucket_object" "archive" {
  provider   = "google"
  name       = "firewall-remediate.zip"
  bucket     = "${google_storage_bucket.bucket.name}"
  source     = "${data.archive_file.source.output_path}"
}

resource "google_service_account" "firewall-remediate-sa" {
  account_id   = "${var.name}-firewall-remediate"
  display_name = "${var.name} firewall remediate"
}

resource "google_project_iam_member" "firewall-remediate-sa-member" {
  project = "${var.project}"
  role    = "roles/compute.networkAdmin"
  member  = "serviceAccount:${google_service_account.firewall-remediate-sa.email}"
}

resource "google_cloudfunctions_function" "firewall-remediate-function" {
  provider              = "google-beta"
  name                  = "${var.name}-firewall-remediate"
  description           = "Google Cloud Function to remediate firewall rules open to the internet"
  available_memory_mb   = 128
  source_archive_bucket = "${google_storage_bucket.bucket.name}"
  source_archive_object = "${google_storage_bucket_object.archive.name}"
  timeout               = 60
  entry_point           = "process_log_entry"
  service_account_email = "${google_service_account.firewall-remediate-sa.email}"
  runtime               = "python37"

  event_trigger = {
    event_type = "google.pubsub.topic.publish"
    resource   = "${google_pubsub_topic.firewall-insert-export-topic.name}"
  }

}