#!/usr/bin/env bash

elf_file=${1}

#pac_flags='-Qo' # local
pac_flags='-F' # remote

readelf_filtered() {
  readelf -d "${elf_file}" | sed -n 's|.*Shared library: \[\([^\]*\)\]|/usr/lib/\1|p'
}

depends='depends=('

for dep in $(readelf_filtered | pacman ${pac_flags}q - | sort -u); do
  depends+="'${dep/*\//}'"
done

depends+=')'
depends="${depends//\'\'/\' \'}"

echo "${depends}"

echo ""
readelf_filtered | pacman ${pac_flags} -
