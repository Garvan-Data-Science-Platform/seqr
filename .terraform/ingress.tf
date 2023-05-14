resource "kubernetes_ingress_v1" "gke-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "gke-ingress"
    annotations = {
        "kubernetes.io/ingress.class"="gce"
        "networking.gke.io/managed-certificates"=google_compute_managed_ssl_certificate.lb_default.name
    }
  }

  spec {
    rule {
      http {
        path {
          path="/*"
          backend {
            service {
                name = "seqr"
                port {
                    number = 80
                }
            }
          }
        }
      }
    }
  }
}

