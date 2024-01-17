terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.5.0"
    }
    kubernetes = {
      source  = "hashicorp/helm"
      version = "2.5.1"
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
  backend "gcs" {
    bucket = "terraform-state-seqr"
    prefix = "prod"
  }
}

module "base" {
    source = "../base"

    project_id = "dsp-seqr"
    region     = "australia-southeast1"
    location = "australia-southeast1-a"
    sa_email = "seqr-prod-sa@dsp-seqr.iam.gserviceaccount.com"
    env = "prod"
    subdomain = "seqr"
    gke_num_nodes = 7
}

output "kubernetes_cluster_name" {
  value       = module.base.kubernetes_cluster_name
  description = "GKE Cluster Name"
}