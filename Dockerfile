FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    clang \
    clang-format \
    clang-tidy \
    make \
    gdb \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
