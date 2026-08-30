#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e

. ./wpicode.env.sh
. ./utils.sh

mkdir -p assets

./prepare_wpicode_portable.sh
./verify_wpicode_build.sh

case "${OS_NAME}" in
  osx)
    BUILD_ROOT="VSCode-darwin-${VSCODE_ARCH}"
    cp THIRD_PARTY_NOTICES.md "${BUILD_ROOT}/WPICodeThirdPartyNotices.txt"
    (
      cd "${BUILD_ROOT}"
      zip -r -X -y \
        "../assets/${ARCHIVE_NAME}-darwin-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" \
        "./${PRODUCT_NAME}.app" \
        "./${BINARY_NAME}-portable-data" \
        ./WPICodeThirdPartyNotices.txt
    )
    ;;
  windows)
    BUILD_ROOT="VSCode-win32-${VSCODE_ARCH}"
    cp THIRD_PARTY_NOTICES.md "${BUILD_ROOT}/WPICodeThirdPartyNotices.txt"
    (
      cd "${BUILD_ROOT}"
      7z.exe a -tzip \
        "../assets/${ARCHIVE_NAME}-win32-${VSCODE_ARCH}-${RELEASE_VERSION}.zip" \
        ./* -r
    )
    ;;
  linux)
    BUILD_ROOT="VSCode-linux-${VSCODE_ARCH}"
    cp THIRD_PARTY_NOTICES.md "${BUILD_ROOT}/WPICodeThirdPartyNotices.txt"
    (
      cd "${BUILD_ROOT}"
      tar czf \
        "../assets/${ARCHIVE_NAME}-linux-${VSCODE_ARCH}-${RELEASE_VERSION}.tar.gz" \
        .
    )
    ;;
  *)
    echo "Unsupported OS_NAME: ${OS_NAME}" >&2
    exit 1
    ;;
esac

if [[ "${OS_NAME}" != "windows" ]]; then
  ./prepare_wpicode_checksums.sh
fi
