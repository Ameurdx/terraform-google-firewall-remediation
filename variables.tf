 variable "org_id" {
     description = "The Organization to associate the project"
 }
 variable "region" {
     description = "The Region which to deploy resources into"
     default     = "us-east1"
 }
  variable "name" {
     description = "The Prefix to apply to resource names"
     default     = "EVD"
 }

 variable "project" {
     description = "The Project to deploy resources to"
 }

 variable "org_sink_filter" {
     description = "The Log Filter to apply to the Org Level export.  Defaults to all activity logs"
     default     = "/logs/cloudaudit.googleapis.com%2Factivity"
 }

 