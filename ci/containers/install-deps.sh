#!/bin/sh
# Shared installer for the suricata CI dependency images.
#
# Usage: install-deps.sh <image-name>
#
# Reads manifests/<image-name>.txt (one package per line, '#' comments and
# blank lines allowed) from the directory this script lives in, installs the
# packages with whichever package manager the base image ships (apt-get,
# dnf or yum), then runs manifests/<image-name>.post.sh if it exists for
# distro-specific extras, and finishes with a generic tool-version sanity
# check so a broken image fails at build time, not in CI.
#
# NOTE on recommends/weak deps: the CI workflows this replaces install with
# the package managers' DEFAULT behaviour (apt with Recommends, dnf with
# weak deps). We deliberately do the same instead of passing
# --no-install-recommends/--setopt=install_weak_deps=False, so the baked
# package set is byte-for-byte what the workflow steps produced.
set -eu

name="$1"
dir=$(cd "$(dirname "$0")" && pwd)
manifest="$dir/manifests/$name.txt"
post="$dir/manifests/$name.post.sh"

[ -f "$manifest" ] || { echo "error: manifest $manifest not found" >&2; exit 1; }

# Strip comments and blank lines. Word-splitting of $pkgs below is intended.
pkgs=$(sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$manifest" | grep -v '^$')

if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    # shellcheck disable=SC2086
    apt-get install -y $pkgs
    rm -rf /var/lib/apt/lists/*
elif command -v dnf >/dev/null 2>&1; then
    # AlmaLinux/CentOS need extra repos enabled, exactly as the workflow
    # jobs enabled them; Fedora does not. EL8 uses powertools (its name
    # for CRB) and -- matching the almalinux-8 job -- no EPEL; EL9+ gets
    # EPEL + CRB.
    if [ -e /etc/almalinux-release ] || [ -e /etc/centos-release ]; then
        if [ "$(rpm --eval '%{rhel}')" = "8" ]; then
            dnf -y install dnf-plugins-core
            dnf config-manager --set-enabled powertools
        else
            dnf -y install dnf-plugins-core epel-release
            dnf config-manager --set-enabled crb
        fi
    fi
    # shellcheck disable=SC2086
    dnf -y install $pkgs
    dnf clean all
elif command -v yum >/dev/null 2>&1; then
    # yum-only fallback; no current image uses this branch (almalinux:8
    # ships dnf, so the EL8 image goes through the dnf branch above).
    yum -y install dnf-plugins-core
    yum config-manager --set-enabled powertools
    # shellcheck disable=SC2086
    yum -y install $pkgs
    yum clean all
else
    echo "error: no supported package manager (apt-get/dnf/yum) found" >&2
    exit 1
fi

if [ -f "$post" ]; then
    echo "--- running $post"
    sh "$post"
fi

# Generic sanity check, tools every image must provide. Post scripts add
# image-specific checks (rustup toolchains, pinned clang versions, ...).
#
# libtool is checked via libtoolize: on Debian/Ubuntu the libtool PACKAGE
# (what the workflows install) ships only libtoolize -- the libtool binary
# lives in libtool-bin, which CI never installed. autogen.sh needs exactly
# libtoolize, and the rpm libtool package provides it too, so this one
# check works on every image.
echo "--- sanity check"
set -x
gcc --version
make --version
autoconf --version
automake --version
libtoolize --version
git --version
python3 --version
