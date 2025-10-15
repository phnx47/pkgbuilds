#!/usr/bin/env bash

set -eu -o pipefail

WORK_DIR=$(pwd)

dirs=$(find . -maxdepth 1 -type d -not -path "*/\.*" -not -path "." | sort)

{
  echo "# Merged nvchecker configuration"
  echo "# Auto-generated - Do not edit directly"
  echo ""
  echo "[__config__]"
  echo "oldver = \"ver.json\""
  echo "newver = \"nver.json\""
  echo ""
} >"$WORK_DIR/nvchecker.toml"

for dir in $dirs; do
  if [ -f "$dir/.nvchecker.toml" ]; then
    {
      cat "$dir/.nvchecker.toml"
      echo ""
    } >>"$WORK_DIR/nvchecker.toml"
  fi
done
