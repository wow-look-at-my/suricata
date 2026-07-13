#!/bin/sh
# Rust extras for suricata-ci-debian-12.
#
# Both covered jobs install Rust via rustup using the MSRV read from
# rust/Cargo.toml.in AT RUN TIME, so those workflow steps are KEPT (a
# future MSRV bump keeps working). Baking the current MSRV toolchain
# (rust/Cargo.toml.in rust-version = "1.75.0") into RUSTUP_HOME
# (/usr/local/rustup, set by the Dockerfile) turns that step into a quick
# no-op until the MSRV changes: the job's rustup-init call writes its
# proxies to $HOME/.cargo/bin as before but finds the toolchain already
# present in RUSTUP_HOME.
set -eu

export CARGO_HOME=/usr/local/cargo
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.75.0 -y --no-modify-path
rm -rf /usr/local/cargo/registry /usr/local/cargo/git

# Image-specific sanity checks.
set -x
/usr/local/cargo/bin/rustup show
/usr/local/cargo/bin/rustup run 1.75.0 cargo --version
clang --version
cmake --version
jq --version
pdflatex --version | head -1
