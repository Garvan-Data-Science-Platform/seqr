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
    es_master_nodes = 3
    es_data_nodes = 2
    es_data_machine = "e2-highmem-4"
    #es_data_machine = "e2-highcpu-32"
}

output "kubernetes_cluster_name" {
  value       = module.base.kubernetes_cluster_name
  description = "GKE Cluster Name"
}

provider "google" {
  project = module.base.project_id
  region  = module.base.region
}

provider "google-beta" {
  project = module.base.project_id
  region  = module.base.region
}