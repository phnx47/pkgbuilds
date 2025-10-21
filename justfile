#!/usr/bin/env -S just --justfile

default:
  just nvcheck

add pkgname:
  .scripts/add-package.sh {{pkgname}}

remove pkgname:
  .scripts/remove-package.sh {{pkgname}}

upgrade pkgname:
  .scripts/upgrade-package.sh {{pkgname}}

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

readelf elf-file:
  .scripts/readelf.sh {{elf-file}}

nvcheck-electron pkgname:
  .scripts/nvcheck-electron.sh {{pkgname}}

merge-nvchecker:
  .scripts/merge-nvchecker.sh
