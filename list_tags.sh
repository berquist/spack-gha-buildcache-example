#!/bin/sh

set -x

# https://stackoverflow.com/a/76038642/
repo="${1:-regclient/regctl}"
# token=$(curl -s "https://ghcr.io/token?service=ghcr.io&scope=repository:${repo}:pull" \
#              -u "${username}:$(cat "${HOME}"/.docker/ghcr_token)" \
#             | jq -r '.token')
token="$(curl -s "https://ghcr.io/token?service=ghcr.io&scope=repository:${repo}:pull")"
curl -H "Authorization: Bearer ${token}" \
     -s "https://ghcr.io/v2/${repo}/tags/list" | jq .
