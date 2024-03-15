# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "repository_name" {
  description = "Name of the container registry"
  type        = string
  default     = ""
}