#!/usr/bin/env bash
# shellcheck disable=SC1091

set -e

. ./wpicode.env.sh
. ./utils.sh

jq -e \
  --arg year "${WPICODE_YEAR}" \
  --arg name "${PRODUCT_NAME}" \
  --arg applicationName "${BINARY_NAME}" \
  '.wpicodeYear == $year
    and .nameShort == $name
    and .nameLong == $name
    and .applicationName == $applicationName
    and .dataFolderName == ("." + $applicationName)
    and .quality == "stable"
    and .darwinBundleIdentifier == "org.wpilib.wpicode2027"' \
  product-wpicode.json >/dev/null

GUID_COUNT="$(
  jq -r '[
    .win32AppId,
    .win32x64AppId,
    .win32arm64AppId,
    .win32UserAppId,
    .win32x64UserAppId,
    .win32arm64UserAppId,
    .win32ContextMenu.x64.clsid,
    .win32ContextMenu.arm64.clsid,
    .darwinProfileUUID,
    .darwinProfilePayloadUUID
  ] | unique | length' product-wpicode.json
)"

if [[ "${GUID_COUNT}" != "10" ]]; then
  echo "The 2027 product GUIDs must all be unique" >&2
  exit 1
fi

if ! jq -e '[
  .win32AppId,
  .win32x64AppId,
  .win32arm64AppId,
  .win32UserAppId,
  .win32x64UserAppId,
  .win32arm64UserAppId,
  .win32ContextMenu.x64.clsid,
  .win32ContextMenu.arm64.clsid,
  .darwinProfileUUID,
  .darwinProfilePayloadUUID
] | all(.[]; (ltrimstr("{{") | rtrimstr("}") | test("^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$")))' product-wpicode.json >/dev/null; then
  echo "The 2027 product GUIDs must be uppercase UUIDv4 values" >&2
  exit 1
fi

for value in \
  "${SHOULD_BUILD_APPIMAGE}" \
  "${SHOULD_BUILD_CLI}" \
  "${SHOULD_BUILD_DEB}" \
  "${SHOULD_BUILD_DMG}" \
  "${SHOULD_BUILD_EXE_SYS}" \
  "${SHOULD_BUILD_EXE_USR}" \
  "${SHOULD_BUILD_MSI}" \
  "${SHOULD_BUILD_MSI_NOUP}" \
  "${SHOULD_BUILD_REH}" \
  "${SHOULD_BUILD_REH_WEB}" \
  "${SHOULD_BUILD_RPM}" \
  "${SHOULD_BUILD_SRC}"; do
  if [[ "${value}" != "no" ]]; then
    echo "A non-archive build target is enabled" >&2
    exit 1
  fi
done

if grep -R -i 'cpptools' product-wpicode.json src/wpicode >/dev/null 2>&1; then
  echo "cpptools must not be configured or bundled" >&2
  exit 1
fi

test "${DISABLE_UPDATE}" = "yes"
test "${SHOULD_BUILD_TAR}" = "yes"
test "${SHOULD_BUILD_ZIP}" = "yes"
test -s src/wpicode/resources/darwin/code.icns
test -s src/wpicode/resources/linux/code.png
test -s src/wpicode/resources/win32/code.ico
grep -q "WPICode ${WPICODE_YEAR}" src/wpicode/resources/linux/code.appdata.xml
grep -q "WPICode ${WPICODE_YEAR}" src/wpicode/resources/win32/VisualElementsManifest.xml
test -f .github/workflows/ci-wpicode-linux.yml
test -f .github/workflows/ci-wpicode-macos.yml
test -f .github/workflows/ci-wpicode-windows.yml

for workflow in .github/workflows/ci-wpicode-{linux,macos,windows}.yml; do
  grep -q "      - \"${WPICODE_YEAR}\"" "${workflow}"
done

test ! -e .github/workflows/ci-build-linux.yml
test ! -e .github/workflows/ci-build-macos.yml
test ! -e .github/workflows/ci-build-windows.yml
test ! -e patches/00-remote-add-url.patch

if compgen -G '.github/workflows/publish-*.yml' >/dev/null; then
  echo "Publish workflows must stay disabled for archive-only CI" >&2
  exit 1
fi

echo "WPICode ${WPICODE_YEAR} configuration is valid"
