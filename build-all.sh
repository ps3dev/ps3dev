#!/bin/sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ -z "${PS3DEV:-}" ]; then
  echo "ERROR: Set \$PS3DEV before continuing."
  exit 1
fi

export PSL1GHT="${PSL1GHT:-$PS3DEV}"
export PATH="$PATH:$PS3DEV/bin:$PS3DEV/ppu/bin:$PS3DEV/spu/bin"

mkdir -p "$ROOT_DIR/build"
cd "$ROOT_DIR/build"

for script in "$ROOT_DIR"/depends/*.sh; do
  [ -e "$script" ] || continue
  sh "$script" || {
    echo "ERROR: $script failed."
    exit 1
  }
done

for script in "$ROOT_DIR"/scripts/*.sh; do
  [ -e "$script" ] || continue
  sh "$script" || {
    echo "ERROR: $script failed."
    exit 1
  }
done
