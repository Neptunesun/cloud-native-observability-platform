variable "workspace_alias" {
  type    = string
  default = "enterprise-platform"
}
variable "archive_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket for long-term telemetry archives."
}
variable "log_retention_days" {
  type    = number
  default = 30
}
variable "tags" {
  type = map(string)
  default = {
    owner       = "platform-observability"
    environment = "shared"
    managed_by  = "terraform"
    cost_center = "cc-observability"
  }
}
