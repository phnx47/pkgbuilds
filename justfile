#!/usr/bin/env -S just --justfile

default:
  just nvcheck

add pkgname:
  git submodule add -b master -f ssh://aur@aur.archlinux.org/{{pkgname}}.git
  git config -f .gitmodules submodule.{{pkgname}}.ignore untracked
  .scripts/sort.gitmodules.sh

init:
  git submodule update --init
  git submodule foreach git checkout master

pull:
  git submodule foreach git pull origin master

publish pkgname:
  cd {{pkgname}}; git push

nvcheck:
  .scripts/nvcheck.sh

update pkgname:
  .scripts/update.sh {{pkgname}}
