#!/usr/bin/env bash

set -eu -o pipefail

pkgname="${1}"

git rm -f "${pkgname}"
rm -rf ".git/modules/${pkgname}"
git config --remove-section "submodule.${pkgname}"
git commit -m "remove ${pkgname} pkg"
