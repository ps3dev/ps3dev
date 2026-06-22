#!/usr/bin/env bash

set -Eeuo pipefail

source "$PS3DEV_ROOT_DIR/utils/common.sh"

PSL1GHT_REPOSITORY="${PSL1GHT_REPO_URL:-https://github.com/ps3dev/PSL1GHT.git}"
PSL1GHT_REF="${PSL1GHT_REF:-master}"
PSL1GHT_SOURCE_DIR="$PS3DEV_BUILD_DIR/PSL1GHT"

require_command "${MAKE:-make}"
require_compiler ppu-gcc
require_compiler spu-gcc

checkout_repository \
    "$PSL1GHT_REPOSITORY" \
    "$PSL1GHT_REF" \
    "$PSL1GHT_SOURCE_DIR"

heading "Building PSL1GHT"

(
    cd "$PSL1GHT_SOURCE_DIR"

    "${MAKE:-make}" install-ctrl
    "${MAKE:-make}"
    "${MAKE:-make}" install
)
