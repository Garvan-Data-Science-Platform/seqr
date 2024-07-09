resource "kubernetes_deployment" "seqr" {
  metadata {
    name = "seqr-${var.env}"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "seqr-${var.env}"
      }
    }
    template {
      metadata {
        labels = {
          App = "seqr-${var.env}"
        }
      }
      spec {
        volume {
          name = "secret-volume"
          secret  {
            secret_name = "elastic-certificate-pem"
          }
        }
        container {
          image = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/seqr:latest"
          name  = "seqr"
          port {
            container_port = 8000
          }
          volume_mount  {
              name = "secret-volume"
              mount_path = "/etc/secret-volume"
              read_only = true
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
            value = "postgres-${var.env}-postgresql"
          }
          env {
            name = "POSTGRES_SERVICE_PORT"
            value = "5432"
          }
          env {
            name = "POSTGRES_USERNAME"
            value = "seqr-user"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = data.google_secret_manager_secret_version.postgres_password.secret_data
          }
          env {
            name = "ELASTICSEARCH_SERVICE_HOSTNAME"
            value = "elasticsearch-master"
          }
          env {
            name = "ELASTICSEARCH_PROTOCOL"
            value = "https"
          }
          env {
            name = "ELASTICSEARCH_CA_PATH"
            value = "/etc/secret-volume/elastic-certificate.pem"
          }
          env {
            name = "SEQR_ES_PASSWORD"
            value = data.google_secret_manager_secret_version.es_password.secret_data
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
            value = "postgres-${var.env}-postgresql"
          }
          env {
            name = "PGPORT"
            value = "5432"
          }
          env {
            name = "PGUSER"
            value = "seqr-user"
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
    annotations = {
      "cloud.google.com/neg": "{\"ingress\": true}",
    }
    name = "seqr-${var.env}"
    labels = {
        App = "seqr-${var.env}"
    }
  }
  spec {
    selector = {
      App = "seqr-${var.env}" #This should match the kubernetes deployment
    }
    port {
      port = 80
      target_port = 8000
    }

    type = "NodePort"
  }
}



