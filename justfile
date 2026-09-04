#!/usr/bin/env -S just --justfile

# List all available commands
default:
  just --list

# Add a new package submodule from AUR
add pkgname:
  .scripts/add-package.sh {{pkgname}}

# Remove a package submodule and its git configuration
remove pkgname:
  .scripts/remove-package.sh {{pkgname}}

# Update package version, rebuild, and push changes
upgrade pkgname:
  .scripts/upgrade-package.sh {{pkgname}}

# Check all packages for new versions and compare with current
nvcheck:
  .scripts/nvcheck-package.sh

# Get latest Electron version used by a specific package
nvcheck-electron pkgname:
  .scripts/nvcheck-electron.sh {{pkgname}}

# Merge all .nvchecker.toml files into main nvchecker.toml
merge-nvchecker:
  .scripts/merge-nvchecker.sh

# Create keyfile.toml with a GitHub token (defaults to `gh auth token`)
keyfile token=`gh auth token`:
  @.scripts/create-keyfile.sh {{token}}

# Initialize submodules and set them to master branch
init:
  git submodule update --init
  git submodule foreach "git config --local status.showUntrackedFiles no && git checkout master"

# Pull latest changes for all submodules
pull:
  .scripts/pull-submodules.sh

# Clean all build artifacts from submodules
clean:
  git submodule foreach git clean -xdf

# Squash the last two commits while keeping the commit message
squash:
  msg="$(git show -s --format=%s)" && git reset --soft HEAD~2 && git commit -m "${msg}"

# Scan an ELF binary for library dependencies
scan-depends elf-file:
  .scripts/scan-depends.sh {{elf-file}}
