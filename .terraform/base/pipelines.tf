#TODO: Check if reference data is loaded, otherwise run:
#copy_reference_data_to_gs.sh $BUILD_VERSION $GS_BUCKET

resource "kubernetes_deployment" "pipeline-runner" {
  metadata {
    name = "pipeline-runner"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "pipeline-runner"
      }
    }
    template {
      metadata {
        labels = {
          App = "pipeline-runner"
        }
      }
      spec {
        container {
          image = "gcr.io/seqr-project/pipeline-runner:latest"
          name  = "pipeline-runner"
          port {
            container_port = 8000
          }
          tty = true
          stdin = true
        }
      }

    }
  }
}

resource "kubernetes_service" "pipeline-runner" {
  metadata {
    name = "pipeline-runner"
    labels = {
        App = "pipeline-runner"
    }
  }
  spec {
    selector = {
      App = "pipeline-runner"
    }
    port {
      port = 80
      target_port = 8000
    }

    type = "NodePort"
  }
}