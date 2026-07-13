#!/bin/sh
# Rust extras for suricata-ci-almalinux-9, replicating what the covered
# jobs installed per-run:
#   1.95.0             = builds.yml RUST_VERSION_KNOWN (almalinux-9 job); default
#   1.85.0             = almalinux-9-templates job pin
#   bindgen-cli 0.66.0 = almalinux-9 job (cargo install bindgen-cli --version 0.66.0)
#   cargo-audit        = rust-checks.yml audit job (unpinned there, so
#                        whatever is latest at image build time)
#
# Installed HOME-independently (RUSTUP_HOME=/usr/local/rustup set by the
# Dockerfile) and deliberately NOT on the default PATH, so jobs that want
# the distro rust-toolset keep resolving /usr/bin/cargo. Jobs opt in with:
#   echo "/usr/local/cargo/bin" >> $GITHUB_PATH
set -eu

export CARGO_HOME=/usr/local/cargo
curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain 1.95.0 -y --no-modify-path
/usr/local/cargo/bin/rustup toolchain install 1.85.0
/usr/local/cargo/bin/cargo install bindgen-cli --version 0.66.0
/usr/local/cargo/bin/cargo install cargo-audit
rm -rf /usr/local/cargo/registry /usr/local/cargo/git

# Image-specific sanity checks.
set -x
/usr/local/cargo/bin/rustup show
/usr/local/cargo/bin/rustup run 1.95.0 cargo --version
/usr/local/cargo/bin/rustup run 1.85.0 cargo --version
/usr/local/cargo/bin/bindgen --version
/usr/local/cargo/bin/cargo-audit --version
cargo --version
rustc --version
cbindgen --version
jq --version
pdflatex --version | head -1
