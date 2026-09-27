#!/usr/bin/env bash

set -euo pipefail

pkgname="${1%/}"

case "${pkgname}" in
ledger-live | ledger-live-git)
  curl -s https://raw.githubusercontent.com/LedgerHQ/ledger-live/refs/heads/main/pnpm-workspace.yaml |
    grep -E '^\s+electron:' | awk '{print $2}'
  ;;

fastmail)
  baseurl="https://dl.fastmailcdn.com/desktop/production/linux/x64"
  appimg="$(curl -s "${baseurl}/latest-linux.yml" | awk '/^path:/ {print $2}')"
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' EXIT
  curl -sLo "${tmpdir}/${appimg}" "${baseurl}/${appimg}"
  chmod +x "${tmpdir}/${appimg}"
  (cd "${tmpdir}" && "./${appimg}" --appimage-extract fastmail >/dev/null)
  grep -aoE 'Electron/[0-9]+\.[0-9]+\.[0-9]+' "${tmpdir}/squashfs-root/fastmail" | head -1 | cut -d/ -f2
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
  echo "Available pkgnames: ledger-live, ledger-live-git, fastmail, cro-chain-desktop, oxen-electron-wallet" >&2
  exit 1
  ;;
esac
