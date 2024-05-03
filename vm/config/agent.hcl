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

template_config {
  exit_on_retry_failure = true
  static_secret_render_interval = "0s"
}

template {
  source = "/etc/vault.d/templates/app.env.ctmpl"
  destination = "/opt/webapp/env/app.env"
  perms = "640"
  group = "www-data"
  exec = {
    command = "systemctl is-active -q gunicorn && systemctl reload gunicorn.service || true"
  }
}

template {
  source = "/etc/vault.d/templates/vault.env.ctmpl"
  destination = "/opt/webapp/env/vault.env"
  perms = "640"
  group = "www-data"
  exec = {
    command = "systemctl is-active -q gunicorn && systemctl reload gunicorn.service || true"
  }
}

template {
  source = "/etc/vault.d/templates/db.env.ctmpl"
  destination = "/opt/webapp/env/db.env"
  perms = "640"
  group = "www-data"
  exec = {
    command = "systemctl is-active -q gunicorn && systemctl reload gunicorn.service || true"
  }
}

# Commented out for demo purposes
// template {
//   source = "/etc/vault.d/templates/aws.env.ctmpl"
//   destination = "/opt/webapp/env/aws.env"
//   perms = "640"
//   group = "www-data"
//   exec = {
//     command = "systemctl is-active -q gunicorn && systemctl reload gunicorn.service || true"
//   }
// }

template {
  source = "/etc/vault.d/templates/pki.cache.ctmpl"
  destination = "/opt/webapp/tls/cache"
  perms = "600"
  exec = {
    command = "systemctl is-active -q gunicorn && systemctl reload gunicorn.service || true"
  }
}
