#!/bin/sh
# Builds libghostty-vt 1.0.0 into $PREFIX (default /opt/libghostty-vt) with
# Zig 0.17.0, both pinned by sha256. No distribution ships libghostty-vt 1.0
# yet; the Debian package links it statically (meson -Dghostty_static=true).
set -eu

PREFIX=${PREFIX:-/opt/libghostty-vt}
ZIG_VERSION=0.17.0
ZIG_SHA256=1cbe9df9f27e6b78d14ccbca43b6703a404ef79ef1c463de901d7f088d4e2026
VT_VERSION=1.0.0
VT_SHA256=4a6ef758be721923e1969e7b81b443dcc92d8dd3fb5a39600c03a8817a753676
VT_DEPS_SHA256=4d5ea5e448e4c7ea8fb55ccbaa8668f2a97d44f438cee831e2b7ecd162d85c29

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"

fetch() { # url sha256
  curl -fsSL --retry 3 -o "$(basename "$1")" "$1"
  echo "$2  $(basename "$1")" | sha256sum -c -
}

fetch "https://ziglang.org/download/$ZIG_VERSION/zig-x86_64-linux-$ZIG_VERSION.tar.xz" "$ZIG_SHA256"
fetch "https://release.files.ghostty.org/libghostty-vt/$VT_VERSION/libghostty-vt-$VT_VERSION.tar.gz" "$VT_SHA256"
fetch "https://release.files.ghostty.org/libghostty-vt/$VT_VERSION/libghostty-vt-$VT_VERSION-deps.tar.gz" "$VT_DEPS_SHA256"
for t in *.tar.*; do tar -xf "$t"; done

# A fresh, empty cache: a populated one can crash Zig with "reached
# unreachable code" (libghostty's PACKAGING-LIBGHOSTTY.md).
export ZIG_GLOBAL_CACHE_DIR="$work/zig-cache"
cd "libghostty-vt-$VT_VERSION"
# -Dcpu=baseline: a build tuned for the CI runner's CPU would crash on older
# machines.
"$work/zig-x86_64-linux-$ZIG_VERSION/zig" build \
  --system "$work/libghostty-vt-$VT_VERSION-deps" \
  -Doptimize=ReleaseFast -Dcpu=baseline \
  --prefix "$PREFIX"
