# WPICode 2027

This repository turns the pinned Code - OSS source used by VSCodium into
WPILib's year-specific, portable editor distribution. It currently builds
**WPICode 2027** from the stable revision in `upstream/stable.json`.

WPICode intentionally produces only these CI artifacts:

- Windows x64 and arm64 portable ZIP archives
- macOS x64 and arm64 portable ZIP archives
- Linux x64 and arm64 portable tar archives
- SHA-1 and SHA-256 checksum files alongside each archive

There are no installers, package-manager packages, standalone CLI archives,
remote-server archives, or insider builds. Microsoft C/C++ (`cpptools`) is not
configured or bundled.

## Portable layout

Windows and Linux archives contain `data/extensions` and
`data/user-data/User/settings.json`. macOS archives contain the application and
its sibling `wpicode-2027-portable-data` directory. The committed settings turn
off editor and extension updates so the WPILib distribution controls upgrades.

## CI

The three `ci-wpicode-*.yml` workflows run for pushes to `master` or `2027`,
pull requests, and manual dispatches. Each workflow builds and verifies its
archives, then uploads them as seven-day GitHub Actions artifacts. No
repository secrets are required for unsigned test builds.

On a new fork, enable GitHub Actions in the repository's **Actions** tab before
the first push. After CI completes, download the artifacts from the workflow
run rather than from Releases.

Run the fast configuration checks locally with:

```bash
./test_wpicode.sh
```

For a local platform build, export `OS_NAME` (`linux`, `osx`, or `windows`),
`VSCODE_ARCH`, `VSCODE_QUALITY=stable`, and `CI_BUILD=no`, then run:

```bash
source ./get_repo.sh
SHOULD_BUILD=yes ./build.sh
./prepare_wpicode_assets.sh
```

## Starting a new year

Do not reuse 2027's identifiers. A yearly rollover must update the names and
year in `wpicode.env.sh`, generate a new set of ten GUIDs and UUIDs in
`product-wpicode.json`, and update the year-specific names in the three
WPICode CI workflows and `src/wpicode` platform metadata. The portable
directory expected by the WPILib tooling and `test_wpicode.sh` should be
updated in the same commit.

WPICode-specific configuration, source overlays, patches, scripts, and CI all
use distinct names or directories. Existing VSCodium files are left unchanged
except for the small hooks in `prepare_vscode.sh` and `build_cli.sh`; obsolete
upstream build and publish workflows are deleted. This keeps upstream rebases
focused on the two integration hooks rather than repeated branding merges.

The icon artwork is sourced from `wpilibsuite/vscode-wpilib` and its license is
recorded in `THIRD_PARTY_NOTICES.md`.

## Upstream

This build system is derived from [VSCodium](https://github.com/VSCodium/vscodium),
which automates building the MIT-licensed
[Microsoft VS Code source](https://github.com/microsoft/vscode). The existing
VSCodium and Microsoft copyright notices remain in `LICENSE` and applicable
source files.
