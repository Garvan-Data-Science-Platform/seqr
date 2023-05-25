resource "kubernetes_persistent_volume" "redis" {
  metadata {
    name = "redis-pv"
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

resource "kubernetes_persistent_volume_claim" "redis" {
  metadata {
    name = "redis-claim"
    labels = {
        App = "redis"
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

resource "kubernetes_deployment" "redis" {
  metadata {
    name = "redis"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "redis"
      }
    }
    template {
      metadata {
        labels = {
          App = "redis"
        }
      }
      spec {
        container {
          image = "redis:7"
          name  = "redis"
          port {
            container_port = 6379
          }
          env {
            name = "POSTGRES_USER"
            value = "seqr-user"
          }

          volume_mount {
            mount_path = "/data"
            name = "redis-volume-mount"
            sub_path = "redis"
          }
        }
        volume {
            name = "redis-volume-mount"
            persistent_volume_claim {
                claim_name = "redis-claim"
            }
      }
      }

    }
  }
}

resource "kubernetes_service" "redis" {
  metadata {
    name = "redis"
    labels = {
        App = "redis"
    }
  }
  spec {
    selector = {
      App = "redis"
    }
    port {
      port = 6379
    }

    type = "ClusterIP"
  }
}



