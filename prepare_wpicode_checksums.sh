#!/usr/bin/env bash

set -e

sum_file() {
  if [[ -f "${1}" ]]; then
    echo "Calculating checksum for ${1}"

    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "${1}" | awk '{ print $1 }' > "${1}.sha256"
      sha1sum "${1}" | awk '{ print $1 }' > "${1}.sha1"
    else
      shasum -a 256 "${1}" | awk '{ print $1 }' > "${1}.sha256"
      shasum -a 1 "${1}" | awk '{ print $1 }' > "${1}.sha1"
    fi
  fi
}

cd assets

for FILE in *.tar.gz *.zip; do
  if [[ -f "${FILE}" ]]; then
    sum_file "${FILE}"
  fi
done

cd ..
