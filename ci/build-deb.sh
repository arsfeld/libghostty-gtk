#!/bin/sh
# Builds the .debs in an elementary OS container (ghcr.io/elementary/docker),
# from a checkout at $PWD. Leaves them in ./dist. Used by .github/workflows/ci.yml.
set -eu

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  ca-certificates curl xz-utils git devscripts equivs lintian >/dev/null

[ -f /opt/libghostty-vt/lib/libghostty-vt.a ] || ci/build-libghostty-vt.sh
export PKG_CONFIG_PATH=/opt/libghostty-vt/lib/pkgconfig

# Each build's version sorts after the last: upstream version, commit date,
# commit.
upstream=$(sed -n "s/^project('libghostty-gtk'.*[ (,]version: '\([^']*\)'.*/\1/p" meson.build | head -n1)
date=$(git log -1 --format=%cd --date=format:%Y%m%d)
sha=$(git rev-parse --short=8 HEAD)
version="$upstream+git$date.$sha"
DEBEMAIL="alex@rosenfeld.one" DEBFULLNAME="Alexandre Rosenfeld" \
  dch --newversion "$version" --distribution noble --force-distribution \
  "Build of $(git rev-parse HEAD)."

mk-build-deps --install --remove --tool 'apt-get -y -qq --no-install-recommends' debian/control >/dev/null
dpkg-buildpackage -b -us -uc

mkdir -p dist
mv ../*.deb ../*.buildinfo ../*.changes dist/
echo "$version" > dist/VERSION

# The public header must not need libghostty-vt's: consumers have none.
dir=$(mktemp -d)
dpkg-deb -x dist/libghostty-gtk-dev_*.deb "$dir"
dpkg-deb -x dist/libghostty-gtk-1-0_*.deb "$dir"
printf '#include <ghostty-gtk.h>\nint main (void) { return ghostty_gtk_terminal_get_type () == 0; }\n' > "$dir/check.c"
pc="$dir/usr/lib/x86_64-linux-gnu/pkgconfig"
sed -i "s|^prefix=.*|prefix=$dir/usr|" "$pc/ghostty-gtk-1.pc"
flags=$(PKG_CONFIG_PATH="$pc" pkg-config --cflags --libs ghostty-gtk-1)
# shellcheck disable=SC2086
cc -o "$dir/check" "$dir/check.c" $flags
LD_LIBRARY_PATH="$dir/usr/lib/x86_64-linux-gnu" "$dir/check"
echo "header check passed"

lintian --allow-root --info dist/*.deb || echo "lintian reported issues (not fatal)"
