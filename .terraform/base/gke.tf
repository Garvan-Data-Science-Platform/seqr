# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.project_id}-gke"
  location = var.location
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name


  #provisioner "local-exec" {
  #  command = "${path.module}/es_cert_setup.sh"
  #}
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = var.es_master_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.project_id
    }

    service_account = var.sa_email

    # preemptible  = true
    machine_type = "e2-standard-2"
    disk_size_gb = 20
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "data_nodes" {
  name       = "dsp-seqr-gke-data"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = var.es_data_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = var.project_id
      type = "data"
    }

    taint {
      key = "dataonly"
      value = "true"
      effect = "NO_SCHEDULE"
    }

    service_account = var.sa_email

    # preemptible  = true
    machine_type = var.es_data_machine
    disk_size_gb = 20
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

data "terraform_remote_state" "gke" {
  backend = "gcs"
  config={
    bucket="terraform-state-seqr"
    prefix="dev"
  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host = google_container_cluster.primary.endpoint
 
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = google_container_cluster.primary.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}