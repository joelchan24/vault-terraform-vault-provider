//enable app role
resource "vault_auth_backend" "approle" {
  type = "approle"
}

# Policies document
data "vault_policy_document" "admin_policy_doc" {
  rule {
    path         = "secret/*"
    capabilities = ["create", "read", "update", "delete", "list"]
    description  = "allow all on secrets"
  }
}


# Policies

resource "vault_policy" "admin_policy" {
  name   = "admin_policy"
  policy = data.vault_policy_document.admin_policy_doc.hcl
}


# Role 

resource "vault_approle_auth_backend_role" "adminrole" {
  backend        = vault_auth_backend.approle.path
  role_name      = var.role_name
  token_policies = ["default", "admin_policy"]
}

# generate roleid
resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.adminrole.role_name
}

#login with approle
resource "vault_approle_auth_backend_login" "login" {
  backend   = vault_auth_backend.approle.path
  role_id   = vault_approle_auth_backend_role.adminrole.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.id.secret_id
}


resource "vault_mount" "kv2-created-by-terraform" {
  path = "secret/"
  type = "kv-v2"
  # or type = "kv"
  description = "This is an example mount for kv version 2"
}

resource "vault_generic_secret" "credentials" {
  path = "secret/credentials"
  depends_on = [vault_mount.kv2-created-by-terraform]
  data_json = <<EOT
{
  "username":   "joel",
  "passworld": "joel24"
}
EOT
}

// Audit devices
# resource "vault_audit" "test" {
#   type = "file"

#   options = {
#     file_path = "/var/log/vault_audit.log"
#   }
# }

// transit engine

resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "Example description"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

# resource "vault_transit_secret_backend_key" "key" {
#   backend = vault_mount.transit.path
#   name    = "my_key"
# }
