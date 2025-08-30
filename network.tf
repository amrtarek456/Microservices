resource "google_project_service" "enable_apis" {
  for_each = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "iap.googleapis.com"
  ])
  project = var.project_id
  service = each.value
}

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.enable_apis]
}

resource "google_compute_subnetwork" "mgmt" {
  name                     = var.mgmt_subnet_name
  ip_cidr_range            = var.mgmt_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  stack_type               = "IPV4_ONLY"
}

resource "google_compute_subnetwork" "gke" {
  name                     = var.gke_subnet_name
  ip_cidr_range            = var.gke_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
  stack_type               = "IPV4_ONLY"

  secondary_ip_range {
    range_name    = "${var.gke_subnet_name}-pods"
    ip_cidr_range = var.pods_secondary_cidr
  }

  secondary_ip_range {
    range_name    = "${var.gke_subnet_name}-services"
    ip_cidr_range = var.services_secondary_cidr
  }
}

resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  region                             = var.region
  router                             = google_compute_router.router.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.gke.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.mgmt.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_firewall" "allow_internal" {
  name      = "${var.network_name}-allow-internal"
  network   = google_compute_network.vpc.name
  direction = "INGRESS"
  source_ranges = [
    var.mgmt_subnet_cidr,
    var.gke_subnet_cidr,
    var.pods_secondary_cidr,
    var.services_secondary_cidr
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "iap_to_bastion_ssh" {
  name          = "${var.network_name}-iap-to-bastion-ssh"
  network       = google_compute_network.vpc.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["bastion"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "master_to_nodes" {
  name          = "${var.network_name}-master-to-nodes"
  network       = google_compute_network.vpc.name
  direction     = "INGRESS"
  source_ranges = [var.master_ipv4_cidr]
  target_tags   = ["gke-node"]

  allow {
    protocol = "tcp"
    ports    = ["443", "10250", "10257", "10259", "30000-32767"]
  }
}
