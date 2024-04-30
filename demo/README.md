# Demo

### Requirements
- [Multipass](https://multipass.run/install)

### Usage

Start the Ubuntu virtual machine
```shell
$ multipass launch -n demo --cloud-init base.yml
```

Check the TTL of the certificate. We use `--insecure` because the demo uses a self-signed certificate.

Here we can we can see the `subject`, `issuer`, `start date`, and `end date`.
```shell
$ export DEMO_IP=$(multipass exec demo -- hostname -I | awk {'print $1'})

$ curl --insecure -vvI https://$DEMO_IP:8000 2>&1 | grep -A4 "Server certificate"

* Server certificate:
*  subject: CN=webapp.example.com
*  start date: Apr 30 14:57:25 2024 GMT
*  expire date: May  1 14:57:55 2024 GMT
*  issuer: CN=example.com Intermediate Authority
```

Hit the various endpoints. Using `GET` for demo purposes.

```shell
$ curl -s --insecure "https://$DEMO_IP:8000/vault/encrypt?message=hello" | jq
{
  "message": "vault:v1:T2r9P2w38PY9Sbvv6D0pXMZYQeIm9ho1CktvkvBw6cnq"
}

$ curl -s --insecure "https://$DEMO_IP:8000/vault/decrypt?message=vault:v1:T2r9P2w38PY9Sbvv6D0pXMZYQeIm9ho1CktvkvBw6cnq" | jq
{
  "message": "hello"
}

$ curl -s --insecure "https://$DEMO_IP:8000/vault/random" | jq                                                               
{
  "message": "KHFCr4Y8Cc7KbZ5WsLhWPxJn6PKKg6iBFtLC20Jjxc021fdKIwVn0r0+noWrTOMv16Q67nXXDPzOuk/RBILEdg=="
}

$ curl -s --insecure "https://$DEMO_IP:8000/sys/info" | jq    
{
  "app": {
    "name": "Awesome API",
    "admin_email": "foo@example.com",
    "api_key": "b208cb4f-66ba-4fc1-8eee-26fdeb71a87c"
  },
  "aws": {
    "access_key": "",
    "secret_key": "",
    "session_token": ""
  },
  "db": {
    "username": "v-approle-demo-mIG1Tw8tZDSWcQ1U2Pu5-1714490101",
    "password": "wSPd4S36uIx-o6SEW1Ys",
    "host": "127.0.0.1",
    "port": "5432",
    "database": "postgres"
  },
  "vault": {
    "proxy_address": "http://127.0.0.1:8100",
    "transit_mount": "transit",
    "transit_key": "demo",
    "transform_mount": "transform",
    "transform_role": "demo"
  }
}
```

View the `gunicorn` logs to verify turnover of worker processes.

```shell
$ multipass exec demo -- journalctl -u gunicorn -n 100 | grep hup -A 42

Apr 30 10:19:45 demo gunicorn[5699]: [2024-04-30 10:19:45 -0500] [5699] [INFO] Handling signal: hup
Apr 30 10:19:45 demo gunicorn[5699]: [2024-04-30 10:19:45 -0500] [5699] [INFO] Hang up: Master
Apr 30 10:19:45 demo systemd[1]: Reloaded "Gunicorn - A Python WSGI HTTP Server for UNIX".
Apr 30 10:19:45 demo gunicorn[6821]: [2024-04-30 10:19:45 -0500] [6821] [INFO] Booting worker with pid: 6821
Apr 30 10:19:45 demo gunicorn[6822]: [2024-04-30 10:19:45 -0500] [6822] [INFO] Booting worker with pid: 6822
Apr 30 10:19:45 demo gunicorn[6823]: [2024-04-30 10:19:45 -0500] [6823] [INFO] Booting worker with pid: 6823
Apr 30 10:19:45 demo gunicorn[6824]: [2024-04-30 10:19:45 -0500] [6824] [INFO] Booting worker with pid: 6824
Apr 30 10:19:45 demo gunicorn[6491]: [2024-04-30 10:19:45 -0500] [6491] [INFO] Shutting down
Apr 30 10:19:45 demo gunicorn[6489]: [2024-04-30 10:19:45 -0500] [6489] [INFO] Shutting down
Apr 30 10:19:45 demo gunicorn[6492]: [2024-04-30 10:19:45 -0500] [6492] [INFO] Shutting down
Apr 30 10:19:45 demo gunicorn[6490]: [2024-04-30 10:19:45 -0500] [6490] [INFO] Shutting down
Apr 30 10:19:45 demo gunicorn[6491]: [2024-04-30 10:19:45 -0500] [6491] [INFO] Waiting for application shutdown.
Apr 30 10:19:45 demo gunicorn[6491]: [2024-04-30 10:19:45 -0500] [6491] [INFO] Application shutdown complete.
Apr 30 10:19:45 demo gunicorn[6491]: [2024-04-30 10:19:45 -0500] [6491] [INFO] Finished server process [6491]
Apr 30 10:19:45 demo gunicorn[6490]: [2024-04-30 10:19:45 -0500] [6490] [INFO] Waiting for application shutdown.
Apr 30 10:19:45 demo gunicorn[6492]: [2024-04-30 10:19:45 -0500] [6492] [INFO] Waiting for application shutdown.
Apr 30 10:19:45 demo gunicorn[6489]: [2024-04-30 10:19:45 -0500] [6489] [INFO] Waiting for application shutdown.
Apr 30 10:19:45 demo gunicorn[6492]: [2024-04-30 10:19:45 -0500] [6492] [INFO] Application shutdown complete.
Apr 30 10:19:45 demo gunicorn[6489]: [2024-04-30 10:19:45 -0500] [6489] [INFO] Application shutdown complete.
Apr 30 10:19:45 demo gunicorn[6490]: [2024-04-30 10:19:45 -0500] [6490] [INFO] Application shutdown complete.
Apr 30 10:19:45 demo gunicorn[6489]: [2024-04-30 10:19:45 -0500] [6489] [INFO] Finished server process [6489]
Apr 30 10:19:45 demo gunicorn[6490]: [2024-04-30 10:19:45 -0500] [6490] [INFO] Finished server process [6490]
Apr 30 10:19:45 demo gunicorn[6492]: [2024-04-30 10:19:45 -0500] [6492] [INFO] Finished server process [6492]
Apr 30 10:19:45 demo gunicorn[5699]: [2024-04-30 10:19:45 -0500] [5699] [ERROR] Worker (pid:6492) was sent SIGTERM!
Apr 30 10:19:45 demo gunicorn[5699]: [2024-04-30 10:19:45 -0500] [5699] [ERROR] Worker (pid:6489) was sent SIGTERM!
Apr 30 10:19:45 demo gunicorn[5699]: [2024-04-30 10:19:45 -0500] [5699] [ERROR] Worker (pid:6490) was sent SIGTERM!
Apr 30 10:19:45 demo gunicorn[5699]: [2024-04-30 10:19:45 -0500] [5699] [ERROR] Worker (pid:6491) was sent SIGTERM!
Apr 30 10:19:46 demo gunicorn[6821]: [2024-04-30 10:19:46 -0500] [6821] [INFO] Started server process [6821]
Apr 30 10:19:46 demo gunicorn[6824]: [2024-04-30 10:19:46 -0500] [6824] [INFO] Started server process [6824]
Apr 30 10:19:46 demo gunicorn[6823]: [2024-04-30 10:19:46 -0500] [6823] [INFO] Started server process [6823]
Apr 30 10:19:46 demo gunicorn[6821]: [2024-04-30 10:19:46 -0500] [6821] [INFO] Waiting for application startup.
Apr 30 10:19:46 demo gunicorn[6823]: [2024-04-30 10:19:46 -0500] [6823] [INFO] Waiting for application startup.
Apr 30 10:19:46 demo gunicorn[6822]: [2024-04-30 10:19:46 -0500] [6822] [INFO] Started server process [6822]
Apr 30 10:19:46 demo gunicorn[6824]: [2024-04-30 10:19:46 -0500] [6824] [INFO] Waiting for application startup.
Apr 30 10:19:46 demo gunicorn[6822]: [2024-04-30 10:19:46 -0500] [6822] [INFO] Waiting for application startup.
Apr 30 10:19:46 demo gunicorn[6821]: [2024-04-30 10:19:46 -0500] [6821] [INFO] Application startup complete.
Apr 30 10:19:46 demo gunicorn[6824]: [2024-04-30 10:19:46 -0500] [6824] [INFO] Application startup complete.
Apr 30 10:19:46 demo gunicorn[6823]: [2024-04-30 10:19:46 -0500] [6823] [INFO] Application startup complete.
Apr 30 10:19:46 demo gunicorn[6822]: [2024-04-30 10:19:46 -0500] [6822] [INFO] Application startup complete.
```

Stop, delete, and purge the Ubuntu virtual machine
```shell
$ multipass delete --purge demo
```
