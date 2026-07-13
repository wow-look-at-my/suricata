#!/bin/sh
# Rust extras for suricata-ci-fedora-44.
#
# rustup 1.86.0 replicates the fedora-44-sv-codecov job's per-run install
# (the packaged Rust has no profiler support built in). HOME-independent
# (RUSTUP_HOME=/usr/local/rustup from the Dockerfile) and deliberately NOT
# on the default PATH, so the other fedora jobs keep using the dnf
# cargo/rustc from /usr/bin exactly as before. sv-codecov opts in with:
#   echo "/usr/local/cargo/bin" >> $GITHUB_PATH
set -eu

export CARGO_HOME=/usr/local/cargo
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.86.0 -y --no-modify-path
rm -rf /usr/local/cargo/registry /usr/local/cargo/git

# Image-specific sanity checks.
set -x
/usr/local/cargo/bin/rustup show
/usr/local/cargo/bin/rustup run 1.86.0 cargo --version
cargo --version
rustc --version
clang --version
cbindgen --version
llvm-profdata merge --help > /dev/null
