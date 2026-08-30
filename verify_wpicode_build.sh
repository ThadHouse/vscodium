#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e

. ./wpicode.env.sh
. ./utils.sh

case "${OS_NAME}" in
  osx)
    BUILD_ROOT="VSCode-darwin-${VSCODE_ARCH}"
    PRODUCT_JSON="${BUILD_ROOT}/${PRODUCT_NAME}.app/Contents/Resources/app/product.json"
    PORTABLE_ROOT="${BUILD_ROOT}/${BINARY_NAME}-portable-data"
    ;;
  windows)
    BUILD_ROOT="VSCode-win32-${VSCODE_ARCH}"
    PRODUCT_JSON="${BUILD_ROOT}/resources/app/product.json"
    PORTABLE_ROOT="${BUILD_ROOT}/data"
    ;;
  linux)
    BUILD_ROOT="VSCode-linux-${VSCODE_ARCH}"
    PRODUCT_JSON="${BUILD_ROOT}/resources/app/product.json"
    PORTABLE_ROOT="${BUILD_ROOT}/data"
    ;;
  *)
    echo "Unsupported OS_NAME: ${OS_NAME}" >&2
    exit 1
    ;;
esac

PRODUCT_JSON="${PRODUCT_JSON}" PRODUCT_NAME="${PRODUCT_NAME}" BINARY_NAME="${BINARY_NAME}" WPICODE_YEAR="${WPICODE_YEAR}" node <<'NODE'
const product = require(`./${process.env.PRODUCT_JSON}`);
const expected = {
  wpicodeYear: process.env.WPICODE_YEAR,
  nameShort: process.env.PRODUCT_NAME,
  nameLong: process.env.PRODUCT_NAME,
  applicationName: process.env.BINARY_NAME,
  dataFolderName: `.${process.env.BINARY_NAME}`,
  quality: 'stable'
};

for (const [key, value] of Object.entries(expected)) {
  if (product[key] !== value) {
    throw new Error(`${key}: expected ${JSON.stringify(value)}, got ${JSON.stringify(product[key])}`);
  }
}

if (product.updateUrl || product.downloadUrl) {
  throw new Error('portable WPICode builds must not advertise an updater or download URL');
}

const yearlyIds = {
  win32AppId: product.win32AppId,
  win32x64AppId: product.win32x64AppId,
  win32arm64AppId: product.win32arm64AppId,
  win32UserAppId: product.win32UserAppId,
  win32x64UserAppId: product.win32x64UserAppId,
  win32arm64UserAppId: product.win32arm64UserAppId,
  win32ContextMenuX64: product.win32ContextMenu?.x64?.clsid,
  win32ContextMenuArm64: product.win32ContextMenu?.arm64?.clsid,
  darwinProfileUUID: product.darwinProfileUUID,
  darwinProfilePayloadUUID: product.darwinProfilePayloadUUID
};

for (const [key, value] of Object.entries(yearlyIds)) {
  if (!value) {
    throw new Error(`missing yearly identity: ${key}`);
  }
}

if (new Set(Object.values(yearlyIds)).size !== Object.keys(yearlyIds).length) {
  throw new Error('yearly product identities must be unique');
}
NODE

test -d "${PORTABLE_ROOT}/extensions"
test -f "${PORTABLE_ROOT}/user-data/User/settings.json"

if find "${BUILD_ROOT}" -iname '*cpptools*' -print -quit | grep -q .; then
  echo "cpptools must not be bundled in WPICode" >&2
  exit 1
fi

echo "Verified ${PRODUCT_NAME} ${OS_NAME}-${VSCODE_ARCH} portable build"
