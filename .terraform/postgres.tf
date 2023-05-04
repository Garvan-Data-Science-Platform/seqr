resource "google_compute_disk" "seqr" {
  name  = "garvan-seqr"
  type  = "pd-ssd"
  zone  = var.region
  #image = "debian-11-bullseye-v20220719"
  size = 5 #Gb
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}

resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "postgres-pv"
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.seqr.name
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name = "postgres-claim"
    labels = {
        App = "postgres"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          App = "postgres"
        }
      }
      spec {
        container {
          image = "postgres:10.3"
          name  = "postgres"
          port {
            container_port = 5432
          }
          env {
            name = "POSTGRES_USER"
            value = "test-user"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "test-password"
          }
          env {
            name = "POSTGRES_DB"
            value = "test-db"
          }

          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name = "postgres-volume-mount"
            sub_path = "postgres"
          }
        }
        volume {
            name = "postgres-volume-mount"
            persistent_volume_claim {
                claim_name = "postgres-claim"
            }
      }
      }

    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
    labels = {
        App = "postgres"
    }
  }
  spec {
    selector = {
      App = "postgres"
    }
    port {
      port = 5432
    }

    type = "ClusterIP"
  }
}