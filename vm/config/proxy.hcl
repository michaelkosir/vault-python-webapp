vault {
  address = "http://127.0.0.1:8200"
}

auto_auth {
  method {
    type = "approle"
    config = {
      role_id_file_path = "/etc/vault.d/auth/roleid"
      secret_id_file_path = "/etc/vault.d/auth/secretid"
      remove_secret_id_file_after_reading = false
    }
  }
}

api_proxy {
  use_auto_auth_token = true
}

# can use a unix socket for additional security
listener "tcp" {
  address = "127.0.0.1:8100"
  tls_disable = true
}