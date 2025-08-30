resource "google_container_cluster" "cluster" {
  name                     = var.cluster_name
  location                 = var.region
  network                  = google_compute_network.vpc.id
  subnetwork               = google_compute_subnetwork.gke.name
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  release_channel { channel = "REGULAR" }

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.gke_subnet_name}-pods"
    services_secondary_range_name = "${var.gke_subnet_name}-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  master_auth {
    client_certificate_config { issue_client_certificate = false }
  }

  depends_on = [
    google_compute_subnetwork.gke,
    google_compute_router_nat.nat
  ]
}

resource "google_container_node_pool" "primary" {
  name       = "${var.cluster_name}-np"
  location   = google_container_cluster.cluster.location
  cluster    = google_container_cluster.cluster.name
  node_count = var.node_count

  node_config {
    machine_type    = var.machine_type
    preemptible     = var.preemptible
    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
    tags            = ["gke-node"]
    metadata        = { disable-legacy-endpoints = "true" }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
