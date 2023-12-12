terraform {
  required_version  = ">=1.6.5"
}

locals {
  app_full_name     = "${var.app_name}-${var.env}-${var.aws_region}"
  default-tags      = {
    "Owner"         = "Andrew Oliver"
    "App"           = "${var.app_name}"
    "ResourceGroup" = "${var.app_name}-${var.env}-${var.aws_region}-app-test"
  }
  app_bucket_name   = "${var.app_name}-${var.env}-${var.aws_region}-bucket"
  rds_instance_name = "${var.app_name}${var.env}useast2rdsdb"
}


