<div align="center">

[![PS3 SDK Release](https://github.com/ps3dev/ps3dev/actions/workflows/build.yml/badge.svg)](https://github.com/ps3dev/ps3dev/actions/workflows/build.yml)

# PS3DEV

Master repo for building the entire suite of PlayStation 3 development tools and environment for end users.

</div>

## Table of Contents

- [PS3DEV](#ps3dev)
  - [Table of Contents](#table-of-contents)
  - [What is PS3DEV?](#what-is-ps3dev)
  - [Quickstart](#quickstart)
  - [Bash variables](#bash-variables)
  - [Dependencies](#dependencies)
  - [Building](#building)


## What is PS3DEV?

`ps3dev` is designed to offer a smooth entry point into developing for the PlayStation 3. It orchestrates the installation of the complete PS3 development environment for all supported platforms.

Start here if you're looking to build code for the PS3.

## Quickstart

You can get started quickly using a pre-built release.

1. Set your [bash variables](#bash-variables) and install [dependencies](#dependencies).
2. Download and extract the [latest release](https://github.com/ps3dev/ps3dev/releases) for your platform.
3. Extract the archive to the `$PS3DEV` folder. By default, this is `/usr/local/ps3dev`.
4. Reload your login script (`source ~/.bash_profile` / `~/.zprofile`).

Done! Verify the installation by checking `ppu-gcc --version`.

## Bash Variables

Add these variables to your login script. If you're on Linux, run `sudo nano ~/.bash_profile`; on macOS, `~/.zprofile` is preferable.

```bash
  export PS3DEV=/usr/local/ps3dev
  export PSL1GHT=$PS3DEV

  export PATH=$PATH:$PS3DEV/bin
  export PATH=$PATH:$PS3DEV/ppu/bin
  export PATH=$PATH:$PS3DEV/spu/bin
```

This is required for the toolchain to work.

Re-open the terminal or run `source ~/.bash_profile` to set the changes.

## Dependencies

### Linux

Run this to install dependencies. 
```
  apt-get install autoconf automake bison flex gcc libelf-dev make \
    texinfo libncurses5-dev patch python subversion wget zlib1g-dev \
    libtool libtool-bin python-dev bzip2 libgmp3-dev pkg-config g++ libssl-dev clang
```

### macOS

Ensure [Homebrew](https://brew.sh/) is installed and run:

```
  brew install autoconf automake openssl libelf ncurses zlib gmp wget pkg-config texinfo
```

Alternatively, there is a script for Linux and macOS that does this for you. Run `sudo ./prepare.sh`.

## Building

You can build the `ps3dev` environment from source.

1. Download the latest release.
2. Add the [bash variables](#bash-variables) to your login script and install [dependencies](#dependencies).
3. Run:
```bash
sudo chown -R $USER: $PS3DEV
./build-all.sh.
```

## Thanks

Special thanks to all of the contributors who developed and maintained the toolchain, libraries and SDK over the years - and to everyone who continues to do so.