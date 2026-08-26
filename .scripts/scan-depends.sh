#!/usr/bin/env bash

elf_file=${1}

#pac_flags='-Qo' # local
pac_flags='-F' # remote

lib_owners=$(
  readelf -d "${elf_file}" |
    sed -n 's|.*Shared library: \[\([^]]*\)\]|/usr/lib/\1|p' |
    pacman --color=always "${pac_flags}" -
)

echo
echo "${lib_owners}" | sed 's|^.* is owned by ||' | sort -u

echo
echo "${lib_owners}" | sort -k5
