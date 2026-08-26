#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

prev_head="$(git rev-parse HEAD)"

git pull --rebase --autostash

# Gitlinks (mode 160000) that the pull advanced
changed=()
while IFS= read -r path; do
  changed+=("${path}")
done < <(git diff --raw "${prev_head}" HEAD | awk '$1 == ":160000" { print $NF }')

if [ "${#changed[@]}" -eq 0 ]; then
  echo "No submodules with new commits."
  exit 0
fi

echo "Pulling submodules: ${changed[*]}"

for path in "${changed[@]}"; do
  echo "==> ${path}"
  git -C "${path}" pull --rebase --autostash origin master
done
