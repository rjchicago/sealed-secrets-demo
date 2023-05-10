#!/bin/sh
set -Eeuo pipefail

mkdir -p temp

openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout ./temp/tls.key \
  -out ./temp/tls.crt \
  -subj "/C=US/ST=IL/L=Chicago/O=Epsilon/OU=IT/CN=*.localhost"

printf "
# COPY TO ./clusters/local/values.yaml
local:
  tls:
    key: $(cat ./temp/tls.key | base64)
    crt: $(cat ./temp/tls.crt | base64)
"
