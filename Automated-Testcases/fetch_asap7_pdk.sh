#!/usr/bin/bash
# Fetches only the ASAP7 files flows/platforms/asap7/*.tcl actually load:
# 4x-scaled LEFs, 4x tech LEF, TT-corner NLDM Liberty libs. Partial clone +
# sparse-checkout, since the full asap7sc7p5t_28 repo is tens of GB.
#
# Needs the `7z` binary (p7zip) on PATH.
#
# Usage: ./fetch_asap7_pdk.sh

set -euo pipefail

if ! command -v 7z >/dev/null 2>&1; then
  echo "FAIL: '7z' not found on PATH -- install p7zip first:" >&2
  echo "  Debian/Ubuntu:  sudo apt install p7zip-full" >&2
  echo "  Fedora/RHEL:    sudo dnf install p7zip p7zip-plugins" >&2
  echo "  macOS (brew):   brew install p7zip" >&2
  exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
SUBMODULE_PATH=Automated-Testcases/PDK/ASAP7
cd "$REPO_ROOT"

# Reads the index, not HEAD -- works even if the submodule is only staged.
SHA=$(git ls-files -s "$SUBMODULE_PATH" | awk '{print $2}')
if [ -z "$SHA" ]; then
  echo "FAIL: $SUBMODULE_PATH isn't a registered submodule in this checkout." >&2
  exit 1
fi

if [ -e "$SUBMODULE_PATH/.git" ]; then
  echo "Submodule already initialized -- reapplying sparse-checkout patterns."
elif [ -d "$SUBMODULE_PATH" ] && [ -n "$(ls -A "$SUBMODULE_PATH" 2>/dev/null)" ]; then
  echo "FAIL: $SUBMODULE_PATH exists and has content but isn't a git checkout." >&2
  echo "  If that's your own PDK data, you're already set -- nothing to do." >&2
  echo "  If you want the submodule instead, move that directory aside first." >&2
  exit 1
else
  echo "Cloning ASAP7 submodule (partial + sparse -- only fetching what's needed)..."
  git submodule init "$SUBMODULE_PATH"
  URL=$(git config -f .gitmodules --get submodule."$SUBMODULE_PATH".url)
  git clone --filter=blob:none --sparse "$URL" "$SUBMODULE_PATH"
fi

git -C "$SUBMODULE_PATH" sparse-checkout set --no-cone \
  '/LEF/scaled/*' \
  '/techlef_misc/asap7_tech_4x_201209.lef' \
  '/LIB/NLDM/*_TT_nldm_*.lib.7z'
git -C "$SUBMODULE_PATH" checkout "$SHA"

# No-op if already absorbed from a previous run -- safe to call every time.
git submodule absorbgitdirs "$SUBMODULE_PATH"

echo "Extracting TT-corner NLDM libs..."
shopt -s nullglob
for archive in "$SUBMODULE_PATH"/LIB/NLDM/*_TT_nldm_*.lib.7z; do
  7z x -y -o"$(dirname "$archive")" "$archive" >/dev/null
  rm -f "$archive"
done
shopt -u nullglob

echo "Done."
echo "  LEF: $SUBMODULE_PATH/LEF/scaled/, $SUBMODULE_PATH/techlef_misc/"
echo "  LIB: $SUBMODULE_PATH/LIB/NLDM/*.lib"
