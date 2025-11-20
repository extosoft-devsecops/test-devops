variable "project_id" {
  description = "GCP project id for nonprod environment"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-southeast1"
}

variable "ingress_host" {
  description = "Ingress host for nonprod environment"
  type        = string
}
