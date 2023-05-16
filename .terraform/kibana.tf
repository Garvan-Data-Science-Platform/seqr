resource "kubernetes_deployment" "kibana" {
  metadata {
    name = "kibana"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "kibana"
      }
    }
    template {
      metadata {
        labels = {
          App = "kibana"
          elasticsearch-master-http-client = "true"
          elasticsearch-master-transport-client = "true"
        }
      }
      spec {
        container {
          image = "kibana:7.16.3"
          name  = "kibana"
          port {
            container_port = 5601
          }
          env {
            name = "ELASTICSEARCH_HOSTS"
            value = "https://elasticsearch-master:9200"
          }

        }
      }

    }
  }
}

resource "kubernetes_service" "kibana" {
  metadata {
    name = "kibana"
    labels = {
        App = "kibana"
    }
  }
  spec {
    selector = {
      App = "kibana"
    }
    port {
      port = 5601
    }

    type = "LoadBalancer"
  }
}



