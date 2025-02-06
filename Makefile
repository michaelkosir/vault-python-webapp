.PHONY: help venv setup dev stop

export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=root

help:	## Show this help message
	@egrep -h '(\s##\s|^##\s)' $(MAKEFILE_LIST) | egrep -v '^--' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m  %-10s\033[0m %s\n", $$1, $$2}'

venv:	## Setup Python virtual environment
	@python3 -m venv ./app/venv
	@./app/venv/bin/pip install --upgrade pip 
	@./app/venv/bin/pip install -r ./app/requirements.txt

env:	## Setup dotenv files for local testing
	@mkdir ./app/env > /dev/null 2>&1 || true

	@echo 'APP_NAME="Awesome API"'  		 		 > ./app/env/app.env
	@echo 'APP_ADMIN_EMAIL="foobar@example.com"'	>> ./app/env/app.env
	@echo 'APP_API_KEY="..."'						>> ./app/env/app.env

	@echo 'AWS_ACCESS_KEY_ID="..."'      > ./app/env/aws.env
	@echo 'AWS_SECRET_ACCESS_KEY="..."' >> ./app/env/aws.env
	@echo 'AWS_SESSION_TOKEN="..."'     >> ./app/env/aws.env

	@echo 'DB_USERNAME="postgres"'   > ./app/env/db.env
	@echo 'DB_PASSWORD="dev"'		>> ./app/env/db.env
	@echo 'DB_HOST="127.0.0.1"'		>> ./app/env/db.env
	@echo 'DB_PORT="5432"'			>> ./app/env/db.env
	@echo 'DB_DATABASE="postgres"'	>> ./app/env/db.env

	@echo 'VAULT_PROXY_ADDRESS="127.0.0.1:8200"'	 > ./app/env/vault.env
	@echo 'VAULT_TRANSIT_MOUNT="transit"'			>> ./app/env/vault.env
	@echo 'VAULT_TRANSIT_KEY="example"'				>> ./app/env/vault.env
	@echo 'VAULT_TRANSFORM_MOUNT="transform"'		>> ./app/env/vault.env
	@echo 'VAULT_TRANSFORM_ROLE="example"'			>> ./app/env/vault.env

setup:  ## Setup Docker containers
	@docker run \
	--name=postgres \
	-p 5432:5432 \
	-e POSTGRES_PASSWORD=dev \
	--net=bridge \
	--detach \
	--rm \
	postgres:16-alpine > /dev/null

	@docker run \
		--name=vault \
		--cap-add=IPC_LOCK \
		--net=bridge \
		-p 8200:8200 \
		-e 'VAULT_DEV_ROOT_TOKEN_ID=root' \
		-e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
		--detach \
		--rm \
		hashicorp/vault:1.16 > /dev/null

	@sleep 1
	@vault secrets enable transit > /dev/null || true
	@vault write transit/keys/example type=aes256-gcm96 > /dev/null || true

dev:	## Launch a dev server
	@if [ ! -d ./app/venv ]; then \
		make venv; \
	fi
	@if [ ! -d ./app/env ]; then \
		make env; \
	fi
	@if ! (docker ps -q --filter "name=postgres" | grep -q . && docker ps -q --filter "name=vault" | grep -q .); then \
		make setup; \
	fi
	@cd ./app && ./venv/bin/uvicorn src.main:app

stop:	## Stop dev server and containers
	@echo "Stopping all services..."
	@docker stop vault postgres > /dev/null 2>&1
	@echo "Services stopped."
