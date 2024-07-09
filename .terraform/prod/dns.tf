resource "google_dns_record_set" "seqr" {

  name = "${module.base.subdomain}.dsp.garvan.org.au."
  type = "A"
  ttl  = 300

  managed_zone = "dsp"
  project = "ctrl-358804"

  rrdatas = [coalesce(data.google_compute_global_address.seqr-static.address,"1.1.1.1")]
}

resource "google_compute_global_address" "seqr-static" {
  name = "ipv4-address-api-prod"
}

data "google_compute_global_address" "seqr-static" {
  depends_on = [google_compute_global_address.seqr-static]
  name = "ipv4-address-api-prod"
}

resource "kubernetes_ingress_v1" "gke-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "gke-ingress"
    annotations = {
        "kubernetes.io/ingress.global-static-ip-name"=google_compute_global_address.seqr-static.name
        "kubernetes.io/ingress.class"="gce"
        "ingress.gcp.kubernetes.io/pre-shared-cert"=module.base.ssl_cert
    }
  }

  spec {
    default_backend {
      service {
        name = "seqr-prod"
        port {
          number = 80
        }
      }
    }
  }
}