terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_kms_key" "observability" {
  description             = "Observability platform encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  tags                    = var.tags
}

resource "aws_prometheus_workspace" "platform" {
  alias = var.workspace_alias
  tags  = var.tags
}

resource "aws_cloudwatch_log_group" "collector" {
  name              = "/platform/observability/otel-collector"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.observability.arn
  tags              = var.tags
}

resource "aws_s3_bucket" "archive" {
  bucket = var.archive_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "archive" {
  bucket                  = aws_s3_bucket.archive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "archive" {
  bucket = aws_s3_bucket.archive.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.observability.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
