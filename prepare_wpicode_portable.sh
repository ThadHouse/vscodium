#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e

. ./wpicode.env.sh
. ./utils.sh

case "${OS_NAME}" in
  osx)
    BUILD_ROOT="VSCode-darwin-${VSCODE_ARCH}"
    PRODUCT_JSON="${BUILD_ROOT}/${PRODUCT_NAME}.app/Contents/Resources/app/product.json"
    ;;
  windows)
    BUILD_ROOT="VSCode-win32-${VSCODE_ARCH}"
    PRODUCT_JSON="${BUILD_ROOT}/resources/app/product.json"
    ;;
  linux)
    BUILD_ROOT="VSCode-linux-${VSCODE_ARCH}"
    PRODUCT_JSON="${BUILD_ROOT}/resources/app/product.json"
    ;;
  *)
    echo "Unsupported OS_NAME: ${OS_NAME}" >&2
    exit 1
    ;;
esac

if [[ ! -f "${PRODUCT_JSON}" ]]; then
  echo "Product metadata not found: ${PRODUCT_JSON}" >&2
  exit 1
fi

APPLICATION_NAME="$( node -p "require('./${PRODUCT_JSON}').applicationName" )"

if [[ "${OS_NAME}" == "osx" ]]; then
  PORTABLE_ROOT="${BUILD_ROOT}/${APPLICATION_NAME}-portable-data"
else
  PORTABLE_ROOT="${BUILD_ROOT}/data"
fi

mkdir -p "${PORTABLE_ROOT}/extensions" "${PORTABLE_ROOT}/user-data/User"
cp build/wpicode/portable-settings.json "${PORTABLE_ROOT}/user-data/User/settings.json"

echo "Prepared portable data at ${PORTABLE_ROOT}"
