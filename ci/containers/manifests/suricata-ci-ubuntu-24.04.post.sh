#!/bin/sh
# Rust extras for suricata-ci-ubuntu-24.04.
#
# rustup 1.85.1 (matches LLVM 19) replicates the per-run install done by
# ubuntu-24-04-cov-ut, ubuntu-24-04-cov-pcapunix, ubuntu-24-04-cov-afpdpdk,
# ubuntu-latest-namespace-ips and ubuntu-24-04-cov-fuzz -- the packaged
# Rust lacks instrument-coverage support. HOME-independent
# (RUSTUP_HOME=/usr/local/rustup from the Dockerfile) and deliberately NOT
# on the default PATH, so cocci/rust-vars/pcap-unix/asan-afpdpdk/formatting
# keep resolving the apt cargo/rustc from /usr/bin exactly as before.
# The rustup jobs opt in with:
#   echo "/usr/local/cargo/bin" >> $GITHUB_PATH
set -eu

export CARGO_HOME=/usr/local/cargo
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.85.1 -y --no-modify-path
rm -rf /usr/local/cargo/registry /usr/local/cargo/git

# Image-specific sanity checks.
set -x
/usr/local/cargo/bin/rustup show
/usr/local/cargo/bin/rustup run 1.85.1 cargo --version
cargo --version
rustc --version
cargo-1.82 --version
rustc-1.82 --version
clang-14 --version
clang-18 --version
clang-19 --version
clang-format-17 --version
llvm-profdata-19 merge --help > /dev/null
llvm-cov-19 --version
spatch --version
cbindgen --version
tshark --version
caddy version
jq --version
