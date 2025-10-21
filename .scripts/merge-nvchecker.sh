#!/usr/bin/env bash

set -eu -o pipefail

work_dir=$(pwd)

dirs=$(find . -maxdepth 1 -type d -not -path "*/\.*" -not -path "." | sort)

{
  echo "# Merged nvchecker configuration"
  echo "# Auto-generated - Do not edit directly"
  echo ""
  echo "[__config__]"
  echo "oldver = \"ver.json\""
  echo "newver = \"nver.json\""
  echo ""
} >"$work_dir/nvchecker.toml"

for dir in $dirs; do
  if [ -f "$dir/.nvchecker.toml" ]; then
    {
      cat "$dir/.nvchecker.toml"
      echo ""
    } >>"$work_dir/nvchecker.toml"
  fi
done

git add nvchecker.toml
git commit -m "merge nvchecker.toml"
