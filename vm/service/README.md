### Location
Store System Service files within the following directory: `/lib/systemd/system/`

### Demo Purposes
The Vault Agent unit file uses `root:root` for simplicity. In Production, follow the principle of least privilege.
Run Vault Agent as `vault:www-data` or `vault:vault` and manage proper permissions to chown rendered secrets and reload systemd services.

### Enable/Start System Service
```shell
$ sudo systemctl enable vault-agent vault-proxy gunicorn --now
```

### References
- https://manpages.ubuntu.com/manpages/focal/en/man5/systemd.service.5.html