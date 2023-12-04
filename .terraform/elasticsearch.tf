
resource "helm_release" "elastic_master" {

  name = "esmaster"

  repository       = "https://helm.elastic.co"
  chart            = "elasticsearch"
  #version          = "7.16.3"

  depends_on = [google_container_node_pool.primary_nodes]

  set {
    name = "imageTag"
    value = "latest"
  }
  set{
    name = "esMajorVersion"
    value = 7
  }
  set{
    name = "image"
    value = "gcr.io/seqr-dev-385323/elasticsearch-gcs"
  }
  set {
    name = "service.type"
    value = "LoadBalancer"
  }
  values = [
    "${file("es_master.yaml")}",
    yamlencode({"extraEnvs":[{"name":"ELASTIC_PASSWORD","value":data.google_secret_manager_secret_version.ESPASSWORD.secret_data}]})
  ]

}

resource "helm_release" "elastic_data" {

  name = "esdata"

  repository       = "https://helm.elastic.co"
  chart            = "elasticsearch"
  #version          = "7.16.3"

  depends_on = [google_container_node_pool.primary_nodes]

  set {
    name = "imageTag"
    value = "latest"
  }
  set{
    name = "esMajorVersion"
    value = 7
  }
  set{
    name = "image"
    value = "gcr.io/seqr-dev-385323/elasticsearch-gcs"
  }
  set {
    name = "service.type"
    value = "LoadBalancer"
  }
  values = [
    "${file("es_data.yaml")}",
    yamlencode({"extraEnvs":[{"name":"ELASTIC_PASSWORD","value":data.google_secret_manager_secret_version.ESPASSWORD.secret_data}]})
  ]

}

/*
resource "kubernetes_persistent_volume" "elasticsearch" {
  metadata {
    name = "es-pv"
  }
  spec {
    capacity = {
      storage = "50Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = google_compute_disk.seqr.name
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "elasticsearch" {
  metadata {
    name = "es-claim"
    labels = {
        App = "es"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "50Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "elasticsearch" {

  metadata {
    name = "elasticsearch"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "es"
      }
    }

    template {
      metadata {
        labels = {
          App = "es"
        }
      }
      
      spec {

        init_container { #This is required to set user permissions to non root user for elasticsearch
          name = "set-user"
          image = "busybox"
          #command = ["sh", "mkdir", "/usr/share/elasticsearch/data"]
          command = ["chown", "-R", "1000:0", "/usr/share/elasticsearch/data"]
          volume_mount {
            mount_path = "/usr/share/elasticsearch/data"
            name = "es-volume-mount"
            sub_path = "elasticsearch"
          }
        }
        
        container {
          image = "docker.elastic.co/elasticsearch/elasticsearch:7.16.3"
          name  = "elasticsearch"
          port {
            container_port = 9200
          }
          env {
            name = "http.host"
            value = "0.0.0.0"
          }
          env {
            name = "discovery.type"
            value = "single-node"
          }
          env {
            name = "cluster.routing.allocation.disk.threshold_enabled"
            value = "false"
          }

          volume_mount {
            mount_path = "/usr/share/elasticsearch/data"
            name = "es-volume-mount"
            sub_path = "elasticsearch"
          }
        }
        volume {
            name = "es-volume-mount"
            persistent_volume_claim {
                claim_name = "es-claim"
            }
        }

      }

    }
  }
}

resource "kubernetes_service" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels = {
        App = "es"
    }
  }
  spec {
    selector = {
      App = "es"
    }
    port {
      port = 9200
    }

    type = "LoadBalancer"
  }
}
*/