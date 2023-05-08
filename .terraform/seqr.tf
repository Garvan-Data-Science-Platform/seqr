resource "kubernetes_deployment" "seqr" {
  metadata {
    name = "seqr"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "seqr"
      }
    }
    template {
      metadata {
        labels = {
          App = "seqr"
        }
      }
      spec {
        container {
          image = "gcr.io/seqr-dev-385323/seqr:latest"
          name  = "seqr"
          port {
            container_port = 8000
          }
          env {
            name = "SEQR_GIT_BRANCH"
            value = "dev"
          }
          env {
            name = "PYTHONPATH"
            value = "/seqr"
          }
          env {
            name = "STATIC_MEDIA_DIR"
            value = "/seqr_static_files"
          }
          env {
            name = "POSTGRES_SERVICE_HOSTNAME"
            value = "postgres"
          }
          env {
            name = "POSTGRES_SERVICE_PORT"
            value = "5432"
          }
          env {
            name = "POSTGRES_USERNAME"
            value = "test-user"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "test-password"
          }
          env {
            name = "ELASTICSEARCH_SERVICE_HOSTNAME"
            value = "es"
          }
          env {
            name = "REDIS_SERVICE_HOSTNAME"
            value = "redis"
          }
          env {
            name = "KIBANA_SERVICE_HOSTNAME"
            value = "kibana"
          }
          env {
            name = "PGHOST"
            value = "postgres"
          }
          env {
            name = "PGPORT"
            value = "5432"
          }
          env {
            name = "PGUSER"
            value = "test-user"
          }
          env {
            name = "GUNICORN_WORKER_THREADS"
            value = "4"
          }
        }
      }

    }
  }
}

resource "kubernetes_service" "seqr" {
  metadata {
    name = "seqr"
    labels = {
        App = "seqr"
    }
  }
  spec {
    selector = {
      App = "seqr"
    }
    port {
      port = 80
      target_port = 8000
    }

    type = "LoadBalancer"
  }
}



