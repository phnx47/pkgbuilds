#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

token="${1:-}"

if [ -z "${token}" ]; then
  echo "Please provide a GitHub token!" >&2
  exit 1
fi

printf '[keys]\ngithub = "%s"\n' "${token}" >keyfile.toml
chmod 600 keyfile.toml

echo "Created keyfile.toml"
