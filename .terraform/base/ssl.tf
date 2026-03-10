resource "google_compute_managed_ssl_certificate" "lb_default" {
  provider = google-beta
  name     = "seqr-${var.env}-ssl-cert-2"

  managed {
    domains = ["${var.subdomain}.dsp.garvan.org.au"]
  }
}

resource "google_compute_ssl_policy" "strict_tls" {
  name            = "seqr-ssl-policy"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "kubernetes_manifest" "seqr_frontend_config" {
  manifest = {
    "apiVersion" = "networking.gke.io/v1beta1"
    "kind"       = "FrontendConfig"
    "metadata" = {
      "name"      = "seqr-frontend-config"
      "namespace" = "default"
    }
    "spec" = {
      "sslPolicy" = google_compute_ssl_policy.strict_tls.name
      "redirectToHttps" = {
        "enabled" = true
      }
    }
  }
}

#resource "google_compute_target_https_proxy" "lb_default" {
#  provider = google-beta
#  name     = "seqr-https-proxy"
#  url_map  = "/*"
#  ssl_certificates = [
#    google_compute_managed_ssl_certificate.lb_default.name
#  ]
#  depends_on = [
#    google_compute_managed_ssl_certificate.lb_default
#  ]
#}