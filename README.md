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

`ps3dev` is designed to offer a smooth entry point into developing for the PS3. It orchestrates the download and building of the complete PS3 dev environment for all supported platforms.

Start here if you're looking to build code for the PlayStation  3.

## Quickstart

You can get started quickly using a pre-built release. Download and extract the [latest release](https://github.com/ps3dev/ps3dev/releases) for your platform and extract it to your `ps3dev` directory in your `path`.

Add the [bash variables](#bash-variables) and you're up and running!

## Bash Variables

Add these variables to your bash config:

```bash
  export PS3DEV=/usr/local/ps3dev
  export PSL1GHT=$PS3DEV

  export PATH=$PATH:$PS3DEV/bin
  export PATH=$PATH:$PS3DEV/ppu/bin
  export PATH=$PATH:$PS3DEV/spu/bin
```

This is required for the toolchain to work.

## Dependencies

### Linux:

Run this to install dependencies. 
```
  apt-get install autoconf automake bison flex gcc libelf-dev make \
    texinfo libncurses5-dev patch python subversion wget zlib1g-dev \
    libtool libtool-bin python-dev bzip2 libgmp3-dev pkg-config g++ libssl-dev clang
```

### macOS:

Ensure Homebrew is installed and run the following:

```
  brew install autoconf automake openssl libelf ncurses zlib gmp wget pkg-config texinfo
```

## Building

You can build the `ps3dev` environment from source. Add the [bash variables](#bash-variables) to your login script (eg. `~/.bash_profile`) and run `build-all.sh`