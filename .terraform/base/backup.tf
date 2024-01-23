resource "kubernetes_deployment" "backup" {
  metadata {
    name = "backup-${var.env}"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "backup-${var.env}"
      }
    }
    template {
      metadata {
        labels = {
          App = "backup-${var.env}"
        }
      }
      spec {
        container {
          image = "australia-southeast1-docker.pkg.dev/dsp-registry-410602/docker/pg-backup:latest"
          name  = "backup"
          env {
            name = "PGPASSWORD"
            value = data.google_secret_manager_secret_version.postgres_password.secret_data
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
            name = "BUCKET"
            value = "gs://seqr-${var.env}-backup"
          }
          env {
            name = "CRON"
            value = "0 0 * * *"
          }
          env {
            name = "DB_LS"
            value = "seqrdb,reference_data_db"
          }
        }
      }
    }
  }
}