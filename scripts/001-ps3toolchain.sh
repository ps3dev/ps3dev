#!/usr/bin/env bash

set -Eeuo pipefail

source "$PS3DEV_ROOT_DIR/utils/common.sh"

TOOLCHAIN_REPOSITORY="${PS3TOOLCHAIN_REPO_URL:-https://github.com/ps3dev/ps3toolchain.git}"
TOOLCHAIN_REF="${PS3TOOLCHAIN_REF:-master}"
TOOLCHAIN_DIR="$PS3DEV_BUILD_DIR/ps3toolchain"

RELEASES_API="${PS3TOOLCHAIN_RELEASES_API:-https://api.github.com/repos/ps3dev/ps3toolchain/releases}"
DOWNLOAD_DIR="$PS3DEV_BUILD_DIR/downloads"

install_prebuilt_toolchain() {
    local asset_os
    local asset_arch
    local asset_name
    local release_data
    local release_tag
    local release_url
    local archive
    local temporary_dir
    local -a curl_headers

    require_command curl
    require_command python3
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

    release_data="$PS3DEV_BUILD_DIR/ps3toolchain-releases.json"

    curl_headers=(
        -H 'Accept: application/vnd.github+json'
        -H 'X-GitHub-Api-Version: 2022-11-28'
        -H 'User-Agent: ps3dev-build-all'
    )

    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        curl_headers+=(
            -H "Authorization: Bearer $GITHUB_TOKEN"
        )
    fi

    heading "Finding the latest $asset_name release"

    curl \
        --fail \
        --location \
        --silent \
        --show-error \
        --retry 3 \
        --retry-delay 2 \
        "${curl_headers[@]}" \
        "$RELEASES_API" \
        -o "$release_data"

    IFS=$'\t' read -r release_tag release_url < <(
        python3 - "$release_data" "$asset_name" <<'PY'
import json
import sys

release_file, wanted_asset = sys.argv[1:]

with open(release_file, "r", encoding="utf-8") as handle:
    releases = json.load(handle)

releases = sorted(
    (
        release
        for release in releases
        if release.get("prerelease") and not release.get("draft")
    ),
    key=lambda release: (
        release.get("published_at")
        or release.get("created_at")
        or ""
    ),
    reverse=True,
)

for release in releases:
    for asset in release.get("assets", []):
        if asset.get("name") == wanted_asset:
            print(
                release.get("tag_name", "untagged"),
                asset["browser_download_url"],
                sep="\t",
            )
            raise SystemExit(0)

raise SystemExit(f"No prerelease contains {wanted_asset}")
PY
    ) || fail "Could not find a suitable ps3toolchain release."

    archive="$DOWNLOAD_DIR/${release_tag}-${asset_name}"

    if [[ ! -s "$archive" ]]; then
        heading "Downloading ps3toolchain $release_tag"

        curl \
            --fail \
            --location \
            --show-error \
            --retry 3 \
            --retry-delay 2 \
            "${curl_headers[@]}" \
            "$release_url" \
            -o "$archive.part"

        mv "$archive.part" "$archive"
    else
        heading "Using cached ps3toolchain $release_tag"
    fi

    temporary_dir="$(
        mktemp -d "${TMPDIR:-/tmp}/ps3toolchain.XXXXXX"
    )"

    trap 'rm -rf "$temporary_dir"' EXIT

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