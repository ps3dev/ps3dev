#!/usr/bin/env bash

set -Eeuo pipefail

heading() {
    printf '\n==> %s\n' "$*"
}

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

install_macos_dependencies() {
    heading "Detected macOS"

    if ! command -v brew >/dev/null 2>&1; then
        fail "Homebrew is required. Install it from https://brew.sh/ and run this script again."
    fi

    eval "$(brew shellenv)"

    heading "Installing ps3dev build dependencies with Homebrew"

    brew install autoconf automake bash bison flex gmp libelf \
    libtool ncurses openssl pkg-config texinfo wget zlib

    cat <<'EOF'

ps3dev dependencies installed successfully.

Homebrew Bash was installed because the ps3dev build scripts require a
modern Bash version. Ensure Homebrew's bin directory appears before /bin
in PATH before running:

  ./build-all.sh

EOF
}

install_apt_dependencies() {
    local sudo_command=()

    heading "Detected Debian-family Linux"

    if (( EUID != 0 )); then
        command -v sudo >/dev/null 2>&1 ||
            fail "This operation requires root privileges, but sudo was not found."

        sudo_command=(sudo)
    fi

    heading "Updating package metadata"

    "${sudo_command[@]}" apt-get update

    heading "Installing ps3dev build dependencies"

    "${sudo_command[@]}" apt-get install -y autoconf automake bison     \
        bzip2 ca-certificates clang curl flex g++ gcc git libelf-dev    \
        libgmp3-dev libncurses5-dev libssl-dev libtool libtool-bin      \
        make patch pkg-config python-is-python3 python3 python3-dev     \
        subversion tar texinfo wget xz-utils zlib1g-dev

    printf '\nps3dev dependencies installed successfully.\n'
}

detect_linux_distribution() {
    local distro_id=""
    local distro_like=""

    [[ -r /etc/os-release ]] ||
        fail "Could not identify this Linux distribution: /etc/os-release is unavailable."

    source /etc/os-release

    distro_id="${ID:-}"
    distro_like="${ID_LIKE:-}"

    case "$distro_id" in
        debian | ubuntu | linuxmint | pop)
            install_apt_dependencies
            return
            ;;
    esac

    case " $distro_like " in
        *" debian "* | *" ubuntu "*)
            install_apt_dependencies
            return
            ;;
    esac

    fail "Linux distribution '$distro_id' is not currently supported by prepare.sh."
}

main() {
    heading "Detecting operating system"

    case "$(uname -s)" in
        Darwin)
            install_macos_dependencies
            ;;
        Linux)
            detect_linux_distribution
            ;;
        *)
            fail "Operating system '$(uname -s)' is not supported."
            ;;
    esac
}

main "$@"