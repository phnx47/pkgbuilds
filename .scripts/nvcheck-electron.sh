#!/usr/bin/env bash

set -euo pipefail

pkgname="${1%/}"

case "${pkgname}" in
ledger-live | ledger-live-git)
  curl -s https://raw.githubusercontent.com/LedgerHQ/ledger-live/refs/heads/main/apps/ledger-live-desktop/package.json |
    jq -r '.devDependencies.electron'
  ;;

cro-chain-desktop)
  curl -s https://raw.githubusercontent.com/crypto-com/chain-desktop-wallet/refs/heads/master/package.json |
    jq -r '.devDependencies.electron'
  ;;

oxen-electron-wallet)
  curl -s https://raw.githubusercontent.com/oxen-io/oxen-electron-gui-wallet/refs/heads/development/package.json |
    jq -r '.devDependencies.electron'
  ;;

*)
  echo "Error: Unknown pkgname '${pkgname}'" >&2
  echo "Available pkgnames: ledger-live, ledger-live-git, cro-chain-desktop, oxen-electron-wallet" >&2
  exit 1
  ;;
esac
