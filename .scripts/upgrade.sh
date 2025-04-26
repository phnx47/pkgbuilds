#!/usr/bin/env bash

set -eu -o pipefail

pkgname="${1%/}"

echo "pkgname=${pkgname}"

if [ -z "${pkgname}" ]; then
  echo "Please provide pkgname!"
  exit 1
fi

nvchecker -e "${pkgname}" -c nvchecker.toml
nver=$(jq -r .data.\""${pkgname}"\".version nver.json)
sed -E -i "s/pkgver=.*/pkgver=${nver}/" "${pkgname}/PKGBUILD"
sed -E -i "s/pkgrel=.*/pkgrel=1/" "${pkgname}/PKGBUILD"

cd "${pkgname}"
updpkgsums
makepkg -scC
makepkg --printsrcinfo >.SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "v${nver}"
cd ..

nvtake "${pkgname}" -c nvchecker.toml
git add "${pkgname}" ver.json
git commit -m "${pkgname}: v${nver}"
