#!/usr/bin/env bash

set -eu -o pipefail

HOOKDIR="$(git rev-parse --git-dir)/hooks"

if [ -d "${HOOKDIR}" ]; then
  grep -lr "Created by Husky" "${HOOKDIR}" | xargs -r -d "\n" rm && echo "husky hooks removed from ${HOOKDIR}"
else
  echo "no git hooks folder found"
  exit 1
fi
