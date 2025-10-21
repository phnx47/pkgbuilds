#!/usr/bin/env bash

set -eu -o pipefail

pkgname="${1}"

git submodule add -b master -f "ssh://aur@aur.archlinux.org/${pkgname}.git"
git config -f .gitmodules "submodule.${pkgname}.ignore" untracked

# sort .gitmodules
awk 'BEGIN { I=0 ; J=0 ; K="" } ; /^\[submodule/{ N+=1 ; J=1 ; K=$2 ; gsub(/("vendor\/|["\]])/, "", K) } ; { print K, N, J, $0 } ; { J+=1 }' .gitmodules |
  sort |
  awk '{ $1="" ; $2="" ; $3="" ; print }' |
  sed 's/^ *//g' |
  awk '/^\[/{ print ; next } { print "\t" $0 }' >.gitmodules.tmp
mv .gitmodules.tmp .gitmodules

git add .gitmodules
git commit -m "add ${pkgname} pkg"
