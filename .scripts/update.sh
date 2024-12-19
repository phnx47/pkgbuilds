#!/usr/bin/env bash

set -eu -o pipefail

pkgname="${1%/}"
srcname="${pkgname%-bin}"

echo "pkgname=${pkgname}"
echo "srcname=${srcname}"

if [ -z "${pkgname}" ]; then
  echo "Please provide pkgname!"
  exit 1
fi

nvchecker -e "${srcname}" -c nvchecker.toml
nver=$(jq -r .data.\""${srcname}"\".version nver.json)
sed -E -i "s/pkgver=.*/pkgver=${nver}/" "${pkgname}/PKGBUILD"
sed -E -i "s/pkgrel=.*/pkgrel=1/" "${pkgname}/PKGBUILD"

src=$(taplo get -f nvchecker.toml "${srcname}".source)

if [ "${src}" = "github" ] && grep -q "_sha=" "${pkgname}/PKGBUILD"; then
  echo "GitHub source with '_sha': using GitHub API"
  repo=$(taplo get -f nvchecker.toml "${srcname}".github)
  vprefix=$(taplo get -f nvchecker.toml "${srcname}".prefix)
  sha=$(curl "https://api.github.com/repos/${repo}/commits/${vprefix}${nver}" | jq -r '.sha')
  sed -i "0,/_sha='.*'/s//_sha='${sha}'/" "${pkgname}/PKGBUILD"
fi

cd "${pkgname}"
updpkgsums
makepkg -scC
makepkg --printsrcinfo >.SRCINFO
git add PKGBUILD .SRCINFO
git commit -m "v${nver}"
cd ..

nvtake "${srcname}" -c nvchecker.toml
git add "${pkgname}" ver.json
git commit -m "${srcname}: v${nver}"
