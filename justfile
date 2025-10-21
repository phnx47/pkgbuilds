#!/usr/bin/env -S just --justfile

default:
  just nvcheck

add pkgname:
  git submodule add -b master -f ssh://aur@aur.archlinux.org/{{pkgname}}.git
  git config -f .gitmodules submodule.{{pkgname}}.ignore untracked
  .scripts/sort-gitmodules.sh
  git add .gitmodules && git commit -m "add '{{pkgname}}' pkg"

remove pkgname:
  git rm -f {{pkgname}}
  rm -rf .git/modules/{{pkgname}}
  git config --remove-section submodule.{{pkgname}}
  git commit -m "remove '{{pkgname}}' pkg"

init:
  git submodule update --init
  git submodule foreach "git config --local status.showUntrackedFiles no && git checkout master"

pull:
  git submodule foreach git pull origin master

clean:
  git submodule foreach git clean -xdf

squash:
  msg="$(git show -s --format=%s)" && git reset --soft HEAD~2 && git commit -m "${msg}"

publish pkgname:
  cd {{pkgname}}; git push

nvcheck:
  nvchecker -c nvchecker.toml -l warning --failures
  nvcmp -c nvchecker.toml

upgrade pkgname:
  .scripts/upgrade.sh {{pkgname}}
  just publish {{pkgname}}

readelf elf-file:
  .scripts/readelf.sh {{elf-file}}

nvcheck-electron pkgname:
  .scripts/nvcheck-electron.sh {{pkgname}}

merge-nvchecker:
  .scripts/merge-nvchecker.sh
