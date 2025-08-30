project_id = "prj-mon-test-iac"

region = "me-central2"
zone   = "me-central2-a"

cluster_name = "demo-gke-private"
machine_type = "e2-small"
node_count   = 1
preemptible  = false

network_name = "gke-vpc"

mgmt_subnet_name = "mgmt-subnet"
mgmt_subnet_cidr = "10.0.0.0/24"

gke_subnet_name = "gke-private-subnet"
gke_subnet_cidr = "10.10.0.0/16"

pods_secondary_cidr     = "10.20.0.0/14"
services_secondary_cidr = "10.50.0.0/20"

master_ipv4_cidr = "172.16.0.0/28"

# Use your real identities or leave empty to skip IAM bindings
iap_members = [
  "a.elboray.c@ncnp.gov.sa"
]
oslogin_admin = true
