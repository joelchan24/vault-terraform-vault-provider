module "vault" {
  source    = "./modules/vault-provider/"
  role_name = "admin"
  typeauth  = "approle"
}
