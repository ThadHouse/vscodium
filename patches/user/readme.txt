Downstream customization
========================

Store user patches in `patches/user`. The build scripts apply every `.patch`
file in that directory to the VS Code source after VSCodium's own patches.

`prepare_vscode.sh` also supports these optional environment variables:

- `VSCODIUM_CUSTOM_ENV`: shell file sourced before source overlays are copied.
  It can export product names and other build configuration.
- `VSCODIUM_CUSTOM_SRC`: directory copied over the VS Code source after the
  selected stable or insider source overlay.
- `VSCODIUM_CUSTOM_PRODUCT_JSON`: JSON object merged over the generated
  `product.json` after VSCodium's product configuration.

Paths may be absolute or relative to the repository root. None of these
variables changes the standard VSCodium build when left unset.
