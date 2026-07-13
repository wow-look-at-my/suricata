# Parameterized CI dependency image for wow-look-at-my/suricata.
#
# One Dockerfile builds every image; the per-distro differences live in
# small manifest files (manifests/<image-name>.txt, one package per line)
# plus an optional manifests/<image-name>.post.sh for distro-specific
# extras (rustup toolchains, cargo-installed tools).
#
# Built by .github/workflows/ci-images.yml as:
#   docker build \
#     --build-arg BASE_IMAGE=<distro:tag> \
#     --build-arg IMAGE_NAME=<image-name> \
#     -t ghcr.io/wow-look-at-my/<image-name>:latest \
#     ci/containers
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG IMAGE_NAME

# HOME-independent rustup location, used by the images whose post script
# bakes Rust toolchains. GitHub Actions container jobs run with
# HOME=/github/home, so anything under /root would be invisible to them.
# Harmless for images that bake no rustup: the distro cargo/rustc are real
# binaries (not rustup proxies) and ignore RUSTUP_HOME.
ENV RUSTUP_HOME=/usr/local/rustup

# Copy only this image's manifest (and its post script when one exists --
# the wildcard always matches at least the .txt).
COPY install-deps.sh /tmp/ci-image/install-deps.sh
COPY manifests/${IMAGE_NAME}.* /tmp/ci-image/manifests/

RUN sh /tmp/ci-image/install-deps.sh "${IMAGE_NAME}" && rm -rf /tmp/ci-image
