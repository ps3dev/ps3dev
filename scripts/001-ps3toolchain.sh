#!/bin/sh

set -eu

REPO_URL="${PS3TOOLCHAIN_REPO_URL:-https://github.com/ps3dev/ps3toolchain.git}"
REPO_REF="${PS3TOOLCHAIN_REF:-master}"
REPO_DIR="${PS3TOOLCHAIN_DIR:-ps3toolchain}"

# Default: build every toolchain stage before PSL1GHT.
#
# CI can override this, for example:
#   PS3TOOLCHAIN_STAGES="1" sh ./build-all.sh
#   PS3TOOLCHAIN_STAGES="1 2" sh ./build-all.sh
#   PS3TOOLCHAIN_STAGES="1 2 4 5 6" sh ./build-all.sh

PS3TOOLCHAIN_STAGES="${PS3TOOLCHAIN_STAGES:-1 2 4 5}"

echo "==> ps3toolchain"
echo "REPO_URL=$REPO_URL"
echo "REPO_REF=$REPO_REF"
echo "REPO_DIR=$REPO_DIR"
echo "PS3TOOLCHAIN_STAGES=$PS3TOOLCHAIN_STAGES"

if [ ! -d "$REPO_DIR/.git" ]; then
  git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" "$REPO_DIR"
else
  git -C "$REPO_DIR" fetch --depth 1 origin "$REPO_REF"
  git -C "$REPO_DIR" checkout --detach FETCH_HEAD
fi

cd "$REPO_DIR"

echo "==> Host"
uname -a || true
uname -m || true

echo "==> Building ps3toolchain stages: $PS3TOOLCHAIN_STAGES"

# Intentional word splitting: stages are passed as individual arguments.
# shellcheck disable=SC2086
./toolchain.sh $PS3TOOLCHAIN_STAGES