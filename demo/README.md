# Demo

### Requirements
- [Multipass](https://multipass.run/install)

### Usage

Start the Ubuntu virtual machine
```shell
$ multipass launch -n demo -c4 -m4G --cloud-init base.yml
```

SSH into the demo VM
```shell
$ multipass shell demo
```

Check the TTL of the certificate. We use `--insecure` because the demo uses a self-signed certificate.

Here we can we can see the `subject`, `issuer`, `start date`, and `end date`.
```shell
$ curl --insecure -vvI https://localhost:8000 2>&1 | grep -A4 "Server certificate"

* Server certificate:
*  subject: CN=webapp.example.com
*  start date: Apr 30 14:57:25 2024 GMT
*  expire date: May  1 14:57:55 2024 GMT
*  issuer: CN=example.com Intermediate Authority
```

Hit the various endpoints. We use `--insecure` because the demo uses a self-signed certificate.

```shell
$ curl -s --insecure -X POST "https://localhost:8000/vault/encrypt" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"message": "hello"}'

{
  "message": "vault:v1:T2r9P2w38PY9Sbvv6D0pXMZYQeIm9ho1CktvkvBw6cnq"
}
```

```shell
$ curl -s --insecure -X POST "https://localhost:8000/vault/decrypt" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"message": "vault:v1:T2r9P2w38PY9Sbvv6D0pXMZYQeIm9ho1CktvkvBw6cnq"}'

{
  "message": "hello"
}
```

```shell
$ curl -s --insecure "https://localhost:8000/vault/random" | jq          

{
  "message": "KHFCr4Y8Cc7KbZ5WsLhWPxJn6PKKg6iBFtLC20Jjxc021fdKIwVn0r0+noWrTOMv16Q67nXXDPzOuk/RBILEdg=="
}
```

```shell
$ curl -s --insecure "https://localhost:8000/sys/info" | jq    

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

Perform load test to verify successful turnover of credentials.
```
$ vegeta attack -insecure -targets=targets.txt -rate=200 -duration=2m | vegeta report
```

View the `gunicorn` logs to verify turnover of worker processes.

```shell
$ journalctl -u gunicorn -n 100 | grep hup -A 40

... Handling signal: hup
... Hang up: Master
... Booting worker with pid: 6821
... Booting worker with pid: 6822
... Booting worker with pid: 6823
... Booting worker with pid: 6824
... Shutting down
... Shutting down
... Shutting down
... Shutting down
... Waiting for application shutdown.
... Application shutdown complete.
... Finished server process [6491]
... Waiting for application shutdown.
... Waiting for application shutdown.
... Waiting for application shutdown.
... Application shutdown complete.
... Application shutdown complete.
... Application shutdown complete.
... Finished server process [6489]
... Finished server process [6490]
... Finished server process [6492]
... Worker (pid:6492) was sent SIGTERM!
... Worker (pid:6489) was sent SIGTERM!
... Worker (pid:6490) was sent SIGTERM!
... Worker (pid:6491) was sent SIGTERM!
... Started server process [6821]
... Started server process [6824]
... Started server process [6823]
... Waiting for application startup.
... Waiting for application startup.
... Started server process [6822]
... Waiting for application startup.
... Waiting for application startup.
... Application startup complete.
... Application startup complete.
... Application startup complete.
... Application startup complete.
```

Exit, Stop, delete, and purge the Ubuntu virtual machine
```shell
$ exit
$ multipass delete --purge demo
```
