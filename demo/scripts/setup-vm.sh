#!/bin/bash

set -e

mkdir /etc/vault.d/templates /etc/vault.d/auth

mv /tmp/vault-python-webapp/app /opt/webapp
mv /tmp/vault-python-webapp/vm/config/*.hcl /etc/vault.d/
mv /tmp/vault-python-webapp/vm/templates/*.ctmpl /etc/vault.d/templates/
mv /tmp/vault-python-webapp/vm/service/*.service /lib/systemd/system/

python3 -m venv /opt/webapp/venv
/opt/webapp/venv/bin/pip install --upgrade pip
/opt/webapp/venv/bin/pip install -r /opt/webapp/requirements.txt

mkdir /opt/webapp/tls
mkdir /opt/webapp/env

# demo purposes, not using AWS
echo 'AWS_ACCESS_KEY_ID="..."'      > /opt/webapp/env/aws.env
echo 'AWS_SECRET_ACCESS_KEY="..."' >> /opt/webapp/env/aws.env
echo 'AWS_SESSION_TOKEN="..."'     >> /opt/webapp/env/aws.env

chown -R www-data:www-data /opt/webapp
chown vault:www-data /opt/webapp/tls
chown vault:www-data /opt/webapp/env
chmod 755 /opt/webapp/tls
chmod 755 /opt/webapp/env

chown -R root:vault /etc/vault.d
chmod -R 640 /etc/vault.d/*
chmod 755 /etc/vault.d/templates /etc/vault.d/auth
