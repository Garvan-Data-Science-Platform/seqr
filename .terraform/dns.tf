
resource "google_dns_record_set" "frontend" {
  name = "${var.domain_name}."
  type = "A"
  ttl  = 300

  managed_zone = "dsp"
  project = "ctrl-358804"

  rrdatas = [data.terraform_remote_state.gke.outputs.load_balancer_ip]
}