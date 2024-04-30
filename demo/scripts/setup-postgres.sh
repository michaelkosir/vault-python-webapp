#!/bin/bash

set -e

docker pull postgres:16-alpine

docker run \
  --name=postgres \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  --detach \
  --rm \
  postgres:16-alpine