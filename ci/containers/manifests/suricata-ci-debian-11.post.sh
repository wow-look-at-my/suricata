#!/bin/sh
# Rust extras for suricata-ci-debian-11.
#
# The covered job installs rustup with --default-toolchain
# $RUST_VERSION_KNOWN (builds.yml, currently 1.95.0) on every run; bake
# that toolchain instead. Installed HOME-independently
# (RUSTUP_HOME=/usr/local/rustup set by the Dockerfile) and deliberately
# NOT on the default PATH. The job opts in with:
#   echo "/usr/local/cargo/bin" >> $GITHUB_PATH
set -eu

export CARGO_HOME=/usr/local/cargo
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.95.0 -y --no-modify-path
rm -rf /usr/local/cargo/registry /usr/local/cargo/git

# Image-specific sanity checks.
set -x
/usr/local/cargo/bin/rustup show
/usr/local/cargo/bin/rustup run 1.95.0 cargo --version
clang --version
ccache --version | head -1
jq --version
