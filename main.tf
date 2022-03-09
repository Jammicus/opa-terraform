resource "tls_self_signed_cert" "example" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12
  early_renewal_hours = 1
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "example" {
   algorithm   = time_rotating.example.id != "" ? "RSA" : "invalid"

}

resource "local_file" "cert" {
    content  = tls_self_signed_cert.example.cert_pem
    filename = "private_key.pem"
}

resource "time_rotating" "example" {
  rotation_minutes = 1
}





