#!/usr/bin/env bash

# Build a package for aarch64 under emulation, to check it compiles before
# declaring aarch64 in arch=(). Needs podman, qemu-user-static(-binfmt),
# systemd-nspawn. Slow; qemu can break steps that work on real hardware.

set -eu -o pipefail

cd "$(dirname "$0")/.."

pkgname="${1}"
image="docker.io/menci/archlinuxarm:base-devel"
root="${TMPDIR:-/tmp}/aarch64-build-${pkgname}"

[ -f "${pkgname}/PKGBUILD" ] || {
  echo "no such package: ${pkgname}/PKGBUILD" >&2
  exit 1
}

command -v systemd-nspawn >/dev/null || {
  echo "missing systemd-nspawn (pacman -S systemd)" >&2
  exit 1
}

[ -x /usr/bin/qemu-aarch64-static ] || {
  echo "missing qemu-aarch64-static (pacman -S qemu-user-static qemu-user-static-binfmt)" >&2
  exit 1
}

echo ":: exporting ${image} rootfs"
sudo rm -rf "${root}"
mkdir -p "${root}"
cid="$(podman create --arch arm64 "${image}" true)"
podman export "${cid}" | tar -x -C "${root}"
podman rm "${cid}" >/dev/null

# qemu-user has no Landlock; pacman's sandbox needs it.
sed -i 's/^#\?DisableSandboxFilesystem/DisableSandboxFilesystem/; s/^#\?DisableSandboxSyscalls/DisableSandboxSyscalls/' "${root}/etc/pacman.conf"
sed -i 's/^DownloadUser/#DownloadUser/' "${root}/etc/pacman.conf"

mkdir -p "${root}/build"
cp "${pkgname}/PKGBUILD" "${root}/build/"
find "${pkgname}" -maxdepth 1 -type f ! -name PKGBUILD ! -name .SRCINFO \
  -exec cp {} "${root}/build/" \;

cat >"${root}/build/run.sh" <<'INNER'
#!/bin/bash
uname -m
grep -E '^(CARCH|LTOFLAGS)=' /etc/makepkg.conf

deps="$(bash -c 'source /build/PKGBUILD; echo ${depends[@]} ${makedepends[@]}' 2>/dev/null || true)"
# shellcheck disable=SC2086
pacman -Sy --noconfirm --needed ${deps} ||
  echo "WARN: some deps failed to install; build may fail"

id -u builder >/dev/null 2>&1 || useradd -m builder
chown -R builder:builder /build /home/builder
cd /build

echo "=== BUILD START $(date -u +%H:%M:%S) ==="
# makepkg won't run as root, and sudo rejects the rootfs ownership.
setpriv --reuid=builder --regid=builder --init-groups \
  env HOME=/home/builder PATH=/usr/local/bin:/usr/bin:/bin \
  makepkg --noconfirm --nocheck 2>&1 | tee /build/build.log
rc="${PIPESTATUS[0]}"
echo "=== BUILD END rc=${rc} $(date -u +%H:%M:%S) ==="

if [ "${rc}" -eq 0 ]; then
  echo "SUCCESS"
  ls -la /build/*.pkg.tar.* 2>/dev/null
fi
exit "${rc}"
INNER
chmod +x "${root}/build/run.sh"

echo ":: building ${pkgname} for aarch64 (slow: emulated)"
echo ":: follow: tail -F ${root}/build/build.log"
sudo systemd-nspawn -q -D "${root}" \
  --bind-ro=/usr/bin/qemu-aarch64-static \
  /build/run.sh

echo
echo ":: full log: ${root}/build/build.log"
echo ":: packages: ${root}/build/"
