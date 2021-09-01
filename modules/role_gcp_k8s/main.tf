resource "google_compute_network" "net" {
  name = "${var.environment}-demo-net-vpc"
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.environment}-demo-net-subnet"
  network       = google_compute_network.net.id
  ip_cidr_range = "10.10.10.0/24"
  region        = var.region
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${var.environment}-demo-net-subnet-svcs"
    ip_cidr_range = "10.10.11.0/24"
  }

  secondary_ip_range {
    range_name    = "${var.environment}-demo-net-subnet-pods"
    ip_cidr_range = "10.1.0.0/16"
  }
}

resource "google_compute_router" "router" {
  name    = "${var.environment}-demo-net-router"
  region  = google_compute_subnetwork.subnet.region
  network = google_compute_network.net.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-demo-net-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  name     = "${var.environment}-demo-cluster"
  location = var.zone

  network  = google_compute_network.net.id
  subnetwork = google_compute_subnetwork.subnet.id

  ip_allocation_policy {
    services_secondary_range_name = google_compute_subnetwork.subnet.secondary_ip_range.0.range_name
    cluster_secondary_range_name  = google_compute_subnetwork.subnet.secondary_ip_range.1.range_name
  }

  private_cluster_config {
    master_ipv4_cidr_block  = "172.16.0.0/28"
    enable_private_endpoint = false
    enable_private_nodes    = true
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = var.admin_ipv4_cidr_block
      display_name = "admin-cidr"
    }
  }

  # Create temporary node-pool to satisfy this block 
  # The managed node pool below will replace it once it builds
  remove_default_node_pool = true
  initial_node_count       = 1
  
}

resource "google_container_node_pool" "nodes" {
  name     = "${var.environment}-demo-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = var.desired_nodes

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type = var.flavor
    image_type   = "COS"

    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}