 variable "org_id" {
     description = "The Organization to associate the project"
 }
  variable "project" {
     description = "The Project to deploy resources to"
 }
 variable "region" {
     description = "The Region which to deploy resources into"
     default     = "us-east1"
 }
  variable "name" {
     description = "The Prefix to apply to resource names"
     default     = "eds"
 }
 variable "org_sink_filter" {
     description = "The Log Filter to apply to the Org Level export.  Defaults to all activity logs"
     default     = "logName:logs/compute.googleapis.com%2Factivity_log resource.type:gce_firewall_rule jsonPayload.event_subtype: (compute.firewalls.insert OR compute.firewalls.update OR compute.firewalls.patch) jsonPayload.event_type:GCE_API_CALL"
 }

 