#!/bin/bash

set -e

docker pull hashicorp/vault:1.16

docker run \
  --name=vault \
  --cap-add=IPC_LOCK \
  -p 8200:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=root' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  --detach \
  --rm \
  hashicorp/vault:1.16

sleep 1

##################
# Policy - TESTING PURPOSES
##################
vault policy write admin - <<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch"]
}
EOF


##################
# AppRole Auth
##################
vault auth enable approle
vault write auth/approle/role/demo token_policies=admin
vault read -field=role_id auth/approle/role/demo/role-id > /etc/vault.d/auth/roleid
vault write -f -field=secret_id auth/approle/role/demo/secret-id > /etc/vault.d/auth/secretid
chown root:vault /etc/vault.d/auth/* 
chmod 640 /etc/vault.d/auth/* 


##################
# Static Secrets
##################
vault secrets enable -version=2 kv
vault kv put kv/demo \
    app_name="Awesome API" \
    app_admin_email="foo@example.com" \
    app_api_key=$(uuidgen) \
    db_host="127.0.0.1" \
    db_port="5432" \
    db_database="postgres" \
    vault_proxy_address="http://127.0.0.1:8100" \
    vault_transit_mount="transit" \
    vault_transit_key="demo" \
    vault_transform_mount="transform" \
    vault_transform_role="demo"


##################
# Database Secrets
##################
export HOST_IP=$(hostname -I | awk '{print $1}')

vault secrets enable -path=pgsql database
vault write pgsql/config/demo \
  plugin_name="postgresql-database-plugin" \
  allowed_roles="demo" \
  connection_url="postgresql://{{username}}:{{password}}@$HOST_IP:5432/postgres" \
  username="postgres" \
  password=$POSTGRES_PASSWORD \
  password_authentication="scram-sha-256"

vault write pgsql/roles/demo \
  db_name="demo" \
  creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' SUPERUSER;" \
  default_ttl="10s" \
  max_ttl="20s"


##################
# Encryption
##################
vault secrets enable transit
vault write transit/keys/demo type="aes256-gcm96"


##################
# PKI Secrets Engine
##################
# Root CA
vault secrets enable -path=pki_root pki
vault secrets tune -max-lease-ttl=87600h pki_root
vault write -field=certificate pki_root/root/generate/internal common_name="example.com" issuer_name="root-2024" ttl=87600h > /tmp/root_2024_ca.crt
# vault write pki_root/roles/2024-servers allow_any_name=true
vault write pki_root/config/urls issuing_certificates="$VAULT_ADDR/v1/pki_root/ca" crl_distribution_points="$VAULT_ADDR/v1/pki_root/crl"

# Intermediate CA
vault secrets enable pki
vault secrets tune -max-lease-ttl=43800h pki
vault write -field=csr pki/intermediate/generate/internal common_name="example.com Intermediate Authority" > /tmp/pki_intermediate.csr
vault write -field=certificate pki_root/root/sign-intermediate issuer_ref="root-2024" csr=@/tmp/pki_intermediate.csr format=pem_bundle ttl="43800h" > /tmp/intermediate.cert.pem
vault write pki/intermediate/set-signed certificate=@/tmp/intermediate.cert.pem
vault write pki/roles/demo issuer_ref="default" allowed_domains="webapp.example.com" allow_subdomains=true allow_bare_domains=true ttl=24h max_ttl=7d

rm /tmp/*.crt /tmp/*.csr /tmp/*.pem