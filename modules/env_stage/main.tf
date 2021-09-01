module "stagiing_demo_cluster" {
  project        = var.project
  environment    = "stage"
  region         = "us-central1"
  zone           = "us-central1-a"
  flavor         = "n1-standard-2"
  desired_nodes  = 3
  source         = "../role_gcp_k8s"
  admin_ipv4_cidr_block = var.admin_ipv4_cidr_block
}