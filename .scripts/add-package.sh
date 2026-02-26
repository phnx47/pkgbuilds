#!/usr/bin/env bash

set -eu -o pipefail

cd "$(dirname "$0")/.."

pkgname="${1}"

git rm -f "${pkgname}"
rm -rf ".git/modules/${pkgname}"
git config --remove-section "submodule.${pkgname}"
git commit -m "remove ${pkgname} pkg"
