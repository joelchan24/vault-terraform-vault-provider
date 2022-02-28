terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "2.23.0"
    }
  }
}
//
provider "vault" {
  skip_tls_verify = true
  # Configuration options
  address = "http://54.81.125.13:8200"
  token   = var.token
}