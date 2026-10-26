#!/bin/bash
hugo server -D --bind 0.0.0.0 --port 1313 \
  --baseURL "https://${CODESPACE_NAME}-1313.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/" \
  --appendPort=false