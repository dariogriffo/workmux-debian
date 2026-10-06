![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/workmux-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/workmux-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/workmux-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/workmux-debian)

<h1>
   <p align="center">
     <a href="https://workmux.raine.dev/"><img src="https://github.com/dariogriffo/workmux-debian/blob/main/workmux.svg" alt="workmux Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/workmux-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>workmux for Debian
   </p>
</h1>
<p align="center">
 workmux orchestrates git worktrees and tmux windows for zero-friction parallel development.
</p>

# workmux for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [workmux](https://github.com/raine/workmux/) hosted at [deb.griffo.io](https://deb.griffo.io)

Currently supported Debian distros are:
- Bookworm (v12)
- Trixie (v13)
- Forky (v14)
- Sid (testing)

Currently supported Ubuntu distros are:
- Jammy (22.04)
- Noble (24.04)
- Questing (25.10)
- Resolute (26.04)

Supported architectures:
- amd64 (x86_64) - All distributions
- arm64 (aarch64) - All distributions

Upstream publishes no i386, armel, armhf or riscv64 binaries, so those
architectures are not available.

The packages include the workmux binary and shell completions for bash, fish
and zsh. Upstream ships no man page; run `workmux docs` for the full
documentation and `workmux --help` for the command reference.

> ℹ️ workmux drives a terminal multiplexer, so the package **depends on `git`**
> and **recommends `tmux`**. tmux is the default backend but kitty, WezTerm and
> Zellij are supported alternatives, which is why it is a recommendation rather
> than a hard dependency.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the workmux source code, see
[workmux](https://github.com/raine/workmux/).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-workmux-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-workmux-in-ubuntu.html)

### The Debian way

> ⚠️ **apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/workmux-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y workmux
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/workmux-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <workmux_version> <build_version> <architecture>
# Example: ./build.sh 0.1.243 1 arm64
```

### Build for all architectures
```sh
./build.sh <workmux_version> <build_version> all
# Example: ./build.sh 0.1.243 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64)

## Disclaimer

- This repo is not open for issues related to workmux. This repo is only for _unofficial_ Debian packaging.
