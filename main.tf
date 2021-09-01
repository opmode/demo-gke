# module "staging" {
#   source = "./modules/env_stage"
# }

module "production" {
  source = "./modules/env_prod"
  project = var.project
  admin_ipv4_cidr_block = var.admin_ipv4_cidr_block
}