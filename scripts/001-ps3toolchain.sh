#!/usr/bin/env bash

set -Eeuo pipefail

source "$PS3DEV_ROOT_DIR/utils/common.sh"

TOOLCHAIN_REPOSITORY="${PS3TOOLCHAIN_REPO_URL:-https://github.com/ps3dev/ps3toolchain.git}"
TOOLCHAIN_REF="${PS3TOOLCHAIN_REF:-master}"
TOOLCHAIN_DIR="$PS3DEV_BUILD_DIR/ps3toolchain"

RELEASE_BASE_URL="${PS3TOOLCHAIN_RELEASE_BASE_URL:-https://github.com/ps3dev/ps3toolchain/releases}"
PINNED_TOOLCHAIN_RELEASE="${PINNED_TOOLCHAIN_RELEASE:-nightly-2026-06-16}"
DOWNLOAD_DIR="$PS3DEV_BUILD_DIR/downloads"

download_archive() {
    local url="$1"
    local destination="$2"

    rm -f "$destination.part"

    if curl \
        --fail \
        --location \
        --silent \
        --show-error \
        --retry 3 \
        --retry-delay 2 \
        --header 'User-Agent: ps3dev-build-all' \
        "$url" \
        --output "$destination.part"
    then
        if [[ ! -s "$destination.part" ]]; then
            rm -f "$destination.part"
            return 1
        fi

        mv "$destination.part" "$destination"
        return 0
    fi

    rm -f "$destination.part"
    return 1
}

install_prebuilt_toolchain() {
    local asset_os
    local asset_arch
    local asset_name
    local release_tag
    local release_url
    local archive
    local temporary_dir

    require_command curl
    require_command tar

    asset_os="$(host_asset_os)" ||
        fail \
            "No prebuilt toolchain is available for $(uname -s). " \
            "Use LOCAL_TOOLCHAIN_BUILD=1."

    asset_arch="$(host_asset_arch)" ||
        fail \
            "No prebuilt toolchain is available for $(uname -m). " \
            "Use LOCAL_TOOLCHAIN_BUILD=1."

    asset_name="ps3dev-${asset_os}-${asset_arch}.tar.gz"

    mkdir -p "$DOWNLOAD_DIR"

    if [[ -n "${PS3TOOLCHAIN_RELEASE_TAG:-}" ]]; then
        release_tag="$PS3TOOLCHAIN_RELEASE_TAG"
        release_url="$RELEASE_BASE_URL/download/$release_tag/$asset_name"
        archive="$DOWNLOAD_DIR/${release_tag}-${asset_name}"

        if [[ -s "$archive" ]]; then
            heading "Using cached ps3toolchain $release_tag"
        else
            heading "Downloading ps3toolchain $release_tag"

            download_archive "$release_url" "$archive" ||
                fail \
                    "Could not download $asset_name from " \
                    "ps3toolchain release $release_tag."
        fi
    else
        release_tag="latest"
        release_url="$RELEASE_BASE_URL/latest/download/$asset_name"
        archive="$DOWNLOAD_DIR/latest-${asset_name}"

        heading "Trying the latest stable ps3toolchain release"

        # The latest release can change without its URL changing, so always
        # refresh this archive instead of trusting a previous download.
        if ! download_archive "$release_url" "$archive"; then
            release_tag="$PINNED_TOOLCHAIN_RELEASE"
            release_url="$RELEASE_BASE_URL/download/$release_tag/$asset_name"
            archive="$DOWNLOAD_DIR/${release_tag}-${asset_name}"

            heading \
                "No stable release found; falling back to ps3toolchain $release_tag"

            if [[ -s "$archive" ]]; then
                heading "Using cached ps3toolchain $release_tag"
            else
                download_archive "$release_url" "$archive" ||
                    fail \
                        "Could not download either the latest stable " \
                        "toolchain or fallback release $release_tag."
            fi
        fi
    fi

    temporary_dir="$(
        mktemp -d "${TMPDIR:-/tmp}/ps3toolchain.XXXXXX"
    )"

    trap 'rm -rf "$temporary_dir"' EXIT

    heading "Extracting ps3toolchain $release_tag"

    tar -xzf "$archive" -C "$temporary_dir"

    [[ -d "$temporary_dir/ps3dev" ]] ||
        fail "Toolchain archive does not contain a ps3dev directory."

    mkdir -p "$PS3DEV"

    tar -C "$temporary_dir/ps3dev" -cf - . |
        tar -C "$PS3DEV" -xf -

    rm -rf "$temporary_dir"
    trap - EXIT

    printf '%s\n' "$release_tag" \
        > "$PS3DEV_BUILD_DIR/ps3toolchain-release.txt"
}

build_local_toolchain() {
    checkout_repository \
        "$TOOLCHAIN_REPOSITORY" \
        "$TOOLCHAIN_REF" \
        "$TOOLCHAIN_DIR"

    heading "Building the PPU and SPU toolchains"

    (
        cd "$TOOLCHAIN_DIR"

        export BUILD_PS3TOOLCHAIN_ONLY=1

        ./toolchain.sh \
            001 \
            002 \
            004 \
            005 \
            006
    )
}

if [[ "${LOCAL_TOOLCHAIN_BUILD:-0}" == "1" ]]; then
    build_local_toolchain
else
    install_prebuilt_toolchain
fi

require_compiler ppu-gcc
require_compiler spu-gcc

ppu-gcc --version | head -n 1
spu-gcc --version | head -n 1