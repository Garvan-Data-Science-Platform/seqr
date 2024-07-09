resource "kubernetes_deployment" "coldstart" {
  metadata {
    name = "coldstart"
  }

  spec {
    selector {
      match_labels = {
        App = "coldstart"
      }
    }
    template {
      metadata {
        labels = {
          App = "coldstart"
        }
      }
      spec {

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "type"
                  operator = "In"
                  values   = ["coldstart"]
                }
              }
            }
          }
        }
        
        toleration {
          key = "CriticalAddonsOnly"
          value = "true"
        }

        container {
          image = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/coldstart:latest"
          name  = "coldstart"
          port {
            container_port = 3000
          }
          env {
            name="PROJ_ID"
            value=module.base.project_id
          }
          env {
            name="NODEPOOL_ID"
            value=module.base.kubernetes_cluster_name
          }
          env {
            name="CLUSTER_ID"
            value=module.base.kubernetes_cluster_name
          }
          env {
            name="ZONE"
            value=module.base.location
          }
          env {
            name="GRPC_DNS_RESOLVER"
            value="native"
          }
          env {
            name="DEPLOYMENT_NAME"
            value="elasticsearch-data"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "coldstart" {
  metadata {
    name = "coldstart"
    labels = {
        App = "coldstart"
    }
  }
  spec {
    selector = {
      App = "coldstart"
    }
    port {
      port = 3000
      target_port = 3000
    }

    type = "NodePort"
  }
}

resource "kubernetes_service" "coldstart-testing" {
  metadata {
    name = "coldstart-testing"
    labels = {
        App = "coldstart"
    }
  }
  spec {
    selector = {
      App = "coldstart"
    }
    port {
      port = 3000
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "coldstart-nginx" {
  metadata {
    name = "coldstart-nginx"
  }

  spec {
    selector {
      match_labels = {
        App = "coldstart-nginx"
      }
    }
    template {
      metadata {
        labels = {
          App = "coldstart-nginx"
        }
      }
      spec {

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "type"
                  operator = "In"
                  values   = ["coldstart"]
                }
              }
            }
          }
        }
        
        toleration {
          key = "CriticalAddonsOnly"
          value = "true"
        }

        container {
          image = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/coldstart-nginx:latest"
          name  = "coldstart"
          port {
            container_port = 80
          }
          env {
            name="TARGET_HOST"
            value="seqr-dev"
          }
          env {
            name="TARGET_PORT"
            value="80"
          }
        }
      }
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "coldstart" {
  name       = "${module.base.kubernetes_cluster_name}-coldstart"
  location   = module.base.location
  cluster    = module.base.kubernetes_cluster_name
  node_count = 1

  #autoscaling {
  #  min_node_count = 1
  #  max_node_count = 50
  #}

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env = module.base.project_id
      type = "coldstart"
    }

    taint {
      key = "CriticalAddonsOnly"
      value = "true"
      effect = "NO_SCHEDULE"
    }

    service_account = module.base.sa_email

    # preemptible  = true
    machine_type = "e2-standard-2"
    disk_size_gb = 10
    tags         = ["gke-node", "${module.base.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

