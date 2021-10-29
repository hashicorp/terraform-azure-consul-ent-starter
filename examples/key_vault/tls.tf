resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca" {
  is_ca_certificate     = true
  key_algorithm         = tls_private_key.ca.algorithm
  private_key_pem       = tls_private_key.ca.private_key_pem
  validity_period_hours = 720 # 30 days

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]

  subject {
    common_name = var.ca_common_name
  }
}

resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server" {
  key_algorithm   = tls_private_key.server.algorithm
  private_key_pem = tls_private_key.server.private_key_pem

  subject {
    common_name = var.shared_san
  }

  dns_names = [
    var.shared_san,
    "localhost",
  ]

  ip_addresses = [
    "127.0.0.1",
  ]
}

resource "tls_locally_signed_cert" "server" {
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  ca_key_algorithm      = tls_private_key.ca.algorithm
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  cert_request_pem      = tls_cert_request.server.cert_request_pem
  validity_period_hours = 720 # 30 days

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]
}

locals {
  tls_data = {
    consul_ca   = base64encode(tls_self_signed_cert.ca.cert_pem)
    consul_cert = base64encode(tls_locally_signed_cert.server.cert_pem)
    consul_pk   = base64encode(tls_private_key.server.private_key_pem)
  }
}

locals {
  secret = jsonencode(local.tls_data)
}
