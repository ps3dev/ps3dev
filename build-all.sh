#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BUILD_DIR="${PS3DEV_BUILD_DIR:-$ROOT_DIR/build}"

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

usage() {
    cat <<EOF
Usage:
  ./build-all.sh                 Build every stage
  ./build-all.sh 1               Build stage 001
  ./build-all.sh 2 3             Build stages 002 and 003
  ./build-all.sh --list          List available stages
  ./build-all.sh --help          Show this help

Environment:
  PS3DEV                        Required absolute installation path
  PSL1GHT                       Defaults to PS3DEV
  PS3DEV_BUILD_DIR              Defaults to ./build
  LOCAL_TOOLCHAIN_BUILD=1       Build ps3toolchain from source
  PS3TOOLCHAIN_REF              Toolchain source ref; defaults to master
  PSL1GHT_REF                   PSL1GHT source ref; defaults to master
  PS3LIBRARIES_REF              ps3libraries source ref; defaults to master
EOF
}

run_script() {
    local script="$1"

    printf '\n============================================================\n'
    printf 'Running %s\n' "$(basename "$script")"
    printf '============================================================\n\n'

    bash "$script" || fail "$(basename "$script") failed."
}

find_stage() {
    local requested="$1"
    local number
    local prefix
    local -a matches

    [[ "$requested" =~ ^[0-9]+$ ]] ||
        fail "Invalid stage '$requested'; expected a number."

    number=$((10#$requested))
    printf -v prefix '%03d' "$number"

matches=()

while IFS= read -r script; do
    matches+=("$script")
done < <(
    find "$ROOT_DIR/scripts" \
        -maxdepth 1 \
        -type f \
        -name "${prefix}-*.sh" \
        -print |
    LC_ALL=C sort
)

    (( ${#matches[@]} > 0 )) ||
        fail "Unknown stage '$requested'."

    (( ${#matches[@]} == 1 )) ||
        fail "More than one script uses stage prefix '$prefix'."

    printf '%s\n' "${matches[0]}"
}

record_build() {
    local build_file="$PS3DEV/build.txt"
    local temporary_file="${build_file}.tmp.$$"
    local component
    local directory

    mkdir -p "$PS3DEV"

    if [[ -f "$build_file" ]]; then
        grep -v -E \
            '^(ps3dev|ps3toolchain|PSL1GHT|ps3libraries) ' \
            "$build_file" > "$temporary_file" || true
    else
        : > "$temporary_file"
    fi

    for component in ps3dev ps3toolchain PSL1GHT ps3libraries; do
        case "$component" in
            ps3dev)
                directory="$ROOT_DIR"
                ;;
            ps3toolchain)
                directory="$BUILD_DIR/ps3toolchain"
                ;;
            PSL1GHT)
                directory="$BUILD_DIR/PSL1GHT"
                ;;
            ps3libraries)
                directory="$BUILD_DIR/ps3libraries"
                ;;
        esac

        if [[ -d "$directory/.git" ]]; then
            git -C "$directory" log -1 \
                --format="$component %H %cs %s" \
                >> "$temporary_file"
        fi
    done

    mv "$temporary_file" "$build_file"
}

[[ "${1:-}" != "--help" ]] || {
    usage
    exit 0
}

[[ -n "${PS3DEV:-}" ]] ||
    fail 'Set $PS3DEV before running build-all.sh.'

[[ "$PS3DEV" = /* ]] ||
    fail '$PS3DEV must be an absolute path.'

[[ "$PS3DEV" != *[[:space:]]* ]] ||
    fail '$PS3DEV must not contain whitespace.'

[[ "$PS3DEV" != "/" ]] ||
    fail '$PS3DEV must not be the filesystem root.'

export PS3DEV
export PSL1GHT="${PSL1GHT:-$PS3DEV}"
export PS3DEV_ROOT_DIR="$ROOT_DIR"
export PS3DEV_BUILD_DIR="$BUILD_DIR"
export NO_SAVANNAH="${NO_SAVANNAH:-1}"
export PATH="$PATH:$PS3DEV/bin:$PS3DEV/ppu/bin:$PS3DEV/spu/bin"

if command -v gmake >/dev/null 2>&1; then
    export MAKE="${MAKE:-gmake}"
else
    export MAKE="${MAKE:-make}"
fi

mkdir -p "$BUILD_DIR" "$PS3DEV"

printf 'PS3DEV build configuration\n'
printf '  Host:       %s %s\n' "$(uname -s)" "$(uname -m)"
printf '  PS3DEV:     %s\n' "$PS3DEV"
printf '  PSL1GHT:    %s\n' "$PSL1GHT"
printf '  Build:      %s\n' "$BUILD_DIR"
printf '  Make:       %s\n' "$MAKE"

# Optional master-repository dependency checks or preparation scripts.
if [[ -d "$ROOT_DIR/depends" ]]; then
DEPEND_SCRIPTS=()

while IFS= read -r script; do
    DEPEND_SCRIPTS+=("$script")
done < <(
    find "$ROOT_DIR/depends" \
        -maxdepth 1 \
        -type f \
        -name '*.sh' \
        -print |
    LC_ALL=C sort
)

    for script in "${DEPEND_SCRIPTS[@]}"; do
        run_script "$script"
    done
fi

BUILD_SCRIPTS=()

while IFS= read -r script; do
    BUILD_SCRIPTS+=("$script")
done < <(
    find "$ROOT_DIR/scripts" \
        -maxdepth 1 \
        -type f \
        -name '[0-9][0-9][0-9]-*.sh' \
        -print |
    LC_ALL=C sort
)

(( ${#BUILD_SCRIPTS[@]} > 0 )) ||
    fail "No build scripts were found under $ROOT_DIR/scripts."

if [[ "${1:-}" == "--list" ]]; then
    printf '\nAvailable stages:\n'

    for script in "${BUILD_SCRIPTS[@]}"; do
        printf '  %s\n' "$(basename "$script" .sh)"
    done

    exit 0
fi

if (( $# > 0 )); then
    for requested_stage in "$@"; do
        run_script "$(find_stage "$requested_stage")"
    done
else
    for script in "${BUILD_SCRIPTS[@]}"; do
        run_script "$script"
    done
fi

record_build

printf '\nPS3DEV build completed successfully.\n'
printf 'Installed environment: %s\n' "$PS3DEV"
