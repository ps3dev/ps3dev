#!/usr/bin/env bash

set -Eeuo pipefail

source "$PS3DEV_ROOT_DIR/utils/common.sh"

PS3LIBRARIES_REPOSITORY="${PS3LIBRARIES_REPO_URL:-https://github.com/ps3dev/ps3libraries.git}"
PS3LIBRARIES_REF="${PS3LIBRARIES_REF:-master}"
PS3LIBRARIES_SOURCE_DIR="$PS3DEV_BUILD_DIR/ps3libraries"

require_compiler ppu-gcc
require_compiler spu-gcc

checkout_repository \
    "$PS3LIBRARIES_REPOSITORY" \
    "$PS3LIBRARIES_REF" \
    "$PS3LIBRARIES_SOURCE_DIR"

heading "Building ps3libraries"

(
    cd "$PS3LIBRARIES_SOURCE_DIR"

    if [[ -n "${PS3LIBRARIES_STAGES:-}" ]]; then
        # Intentional splitting: each requested library stage becomes
        # one positional argument to libraries.sh.
        # shellcheck disable=SC2086
        ./libraries.sh $PS3LIBRARIES_STAGES
    else
        ./libraries.sh
    fi
)
