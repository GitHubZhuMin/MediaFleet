# Cursor Cloud Agent base image.
# Do not COPY the repository. Cursor checks out the commit and runs install itself.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    UV_LINK_MODE=copy

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        sudo \
        build-essential \
        pkg-config \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/* \
    && (id -u ubuntu >/dev/null 2>&1 || useradd -m -s /bin/bash ubuntu) \
    && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

# Match .github/workflows/ci.yml. Install system-wide so the ubuntu user can call uv.
RUN curl -LsSf https://astral.sh/uv/0.12.20/install.sh | env UV_INSTALL_DIR=/usr/local/bin sh \
    && uv --version
