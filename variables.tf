variable "admin_ipv4_cidr_block" {
  type = string
  description = "Please provide the admin CIDR range for whitelisted access to the control plane endpoint"
}

variable "project" {
  type = string
  description = "Please provide your GCP project name"
}