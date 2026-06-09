#!/bin/sh

set -eu

REPO_URL="${PS3TOOLCHAIN_REPO_URL:-https://github.com/ps3dev/ps3toolchain.git}"
REPO_REF="${PS3TOOLCHAIN_REF:-master}"
REPO_DIR="ps3toolchain"

if [ ! -d "$REPO_DIR/.git" ]; then
  git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" "$REPO_DIR"
else
  git -C "$REPO_DIR" fetch --depth 1 origin "$REPO_REF"
  git -C "$REPO_DIR" checkout --detach FETCH_HEAD
fi

cd "$REPO_DIR"

# Build every toolchain stage before PSL1GHT
./toolchain.sh 1 2 4 5 6
