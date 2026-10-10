#!/usr/bin/env bash

elf_file=${1}

#pac_flags='-Qo' # local
pac_flags='-F' # remote

dynamic=$(readelf -d "${elf_file}") || exit
libs=$(echo "${dynamic}" | sed -n 's|.*Shared library: \[\([^]]*\)\]|/usr/lib/\1|p')

if [[ -z ${libs} ]]; then
  echo "${dynamic:-No shared library dependencies found.}"
  exit 0
fi

lib_owners=$(echo "${libs}" | pacman --color=always "${pac_flags}" -)

echo
echo "${lib_owners}" | sed 's|^.* is owned by ||' | sort -u

echo
echo "${lib_owners}" | sort -k5
