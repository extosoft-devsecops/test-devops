variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region สำหรับ GKE (เช่น asia-southeast1)"
  type        = string
  default     = "asia-southeast1"
}

variable "prod_ingress_host" {
  description = "DNS hostname สำหรับ prod ingress (เช่น prod.test-devops.example.com) ถ้ายังไม่มี ใส่เป็น null หรือเว้นว่างแล้วใช้ IP ตรง ๆ"
  type        = string
  default     = ""
}

variable "nonprod_ingress_host" {
  description = "DNS hostname สำหรับ nonprod ingress"
  type        = string
  default     = ""
}
