#!/usr/bin/env bash

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

heading() {
    printf '\n==> %s\n' "$*"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        fail "Required command not found: $1"
}

require_compiler() {
    local compiler="$1"

    command -v "$compiler" >/dev/null 2>&1 ||
        fail \
            "$compiler was not found. Build or install the toolchain " \
            "before running this stage."
}

checkout_repository() {
    local repository_url="$1"
    local repository_ref="$2"
    local repository_dir="$3"

    require_command git

    if [[ -d "$repository_dir/.git" ]]; then
        heading "Updating $(basename "$repository_dir")"

        git -C "$repository_dir" fetch \
            --depth 1 \
            origin \
            "$repository_ref"

        git -C "$repository_dir" checkout \
            --detach \
            FETCH_HEAD
    else
        [[ ! -e "$repository_dir" ]] ||
            fail "$repository_dir exists but is not a Git repository."

        heading "Cloning $(basename "$repository_dir")"

        mkdir -p "$repository_dir"

        git -C "$repository_dir" init
        git -C "$repository_dir" remote add origin "$repository_url"
        git -C "$repository_dir" fetch \
            --depth 1 \
            origin \
            "$repository_ref"

        git -C "$repository_dir" checkout \
            --detach \
            FETCH_HEAD
    fi
}

host_asset_os() {
    case "$(uname -s)" in
        Linux)
            printf 'linux\n'
            ;;
        Darwin)
            printf 'macos\n'
            ;;
        *)
            return 1
            ;;
    esac
}

host_asset_arch() {
    case "$(uname -m)" in
        x86_64 | amd64)
            printf 'X64\n'
            ;;
        arm64 | aarch64)
            printf 'ARM64\n'
            ;;
        *)
            return 1
            ;;
    esac
}