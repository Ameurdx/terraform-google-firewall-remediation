project         = "cleibl-splunkexport-testing"
org_id          = "614830067722"
region          = "us-east1"
name            = "eds"
org_sink_filter = "logName:logs/compute.googleapis.com%2Factivity_log resource.type:gce_firewall_rule jsonPayload.event_subtype:compute.firewalls.insert jsonPayload.event_type:GCE_API_CALL"
