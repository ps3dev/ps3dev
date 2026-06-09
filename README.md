<div align="center">

[![CI](https://github.com/ps3dev/ps3dev/actions/workflows/build.yml/badge.svg)](https://github.com/ps3dev/ps3dev/actions/workflows/build.yml)

# PS3DEV

Master repo for building the entire suite of PlayStation 3 development tools and environment for end users.

</div>

## Table of Contents

- [PS3DEV](#ps3dev)
  - [Table of Contents](#table-of-contents)
  - [What is PS3DEV?](#what-is-ps3dev)
  - [Building](#building)
  - [To-Do](#to-do)


## What is PS3DEV?

`ps3dev` is designed to offer a smooth entry point into developing for the PS3. This repository will host master build scripts and pre-built [releases](https://github.com/ps3dev/ps3dev/releases) for quick-starting.

Currently, [ps3toolchain](https://github.com/ps3dev/ps3toolchain) builds not just the toolchain, but has dependency on PSL1GHT's Newlib. The goal of `ps3dev` is to create healthy separation of concerns, separating the roles of toolchain and SDK. This means:
- Clearer troubleshooting
- Easier maintenance
- More stable builds
- Points of failure are distinct
- Toolchain not tied to a single SDK


## Building

Set `PS3DEV` to an absolute, writable installation path and run:

```sh
export PS3DEV=/usr/local/ps3dev
sh ./build-all.sh
```

The current bootstrap stage clones [ps3toolchain](https://github.com/ps3dev/ps3toolchain) and builds its five pre-PSL1GHT scripts: `001`, `002`, `004`, `005`, and `006`.


## To-Do

> [!NOTE]
> The time of writing is June 3, 2026. This README may not be the most up-to-date source of truth in the future.
> Verify current conditions for yourself in the PSL1GHT and ps3toolchain repositories.

- Remove PSL1GHT dependency from the toolchain
- Ensure stable builds on Linux and macOS
- Automate pre-built releases
- Set up Docker
- Expand CI to cover PSL1GHT and ps3libraries stages
- Update outdated libraries and compilers
- ...
- Make PS3 a high-quality, accessible platform for homebrew development, with best practices, good code hygiene and polished resources!
