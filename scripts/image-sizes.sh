#!/usr/bin/env bash
# Report the installed packages of a built OCI image by size, largest first —
# a quick way to see which tools dominate the image and where to trim.
#
# Alpine/apko record each package's installed size (bytes) in the I: field of
# /lib/apk/db/installed, so we just pull that database out of the image and
# summarize it. The image must be loaded into Docker; if it isn't, this builds
# and loads it via the Makefile first.
#
#   ./scripts/image-sizes.sh                 # defaults: IMAGE=dbug TAG=latest
#   IMAGE=dbug TAG=latest ARCH=arm64 ./scripts/image-sizes.sh
set -euo pipefail

IMAGE="${IMAGE:-dbug}"
TAG="${TAG:-latest}"
ARCH="${ARCH:-$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/')}"
DOCKER="${DOCKER:-docker}"

REF="$IMAGE:$TAG"
# apko appends the arch when loading a single-arch tarball, so `docker load`
# produces REF-ARCH, not REF (matches LOADREF in the Makefile).
LOADREF="$REF-$ARCH"

if ! "$DOCKER" image inspect "$LOADREF" >/dev/null 2>&1; then
  echo "Image $LOADREF not found locally; building + loading…" >&2
  make load IMAGE="$IMAGE" TAG="$TAG" ARCH="$ARCH" >&2
fi

echo "Installed packages in $LOADREF by size:" >&2

"$DOCKER" run --rm --entrypoint cat "$LOADREF" /lib/apk/db/installed \
  | awk '/^P:/ { name = substr($0, 3) }
         /^I:/ { print substr($0, 3) + 0 "\t" name }' \
  | sort -rn \
  | awk -F'\t' '
      function human(b,   u, i) {
        split("B KiB MiB GiB", u, " ")
        i = 1
        while (b >= 1024 && i < 4) { b /= 1024; i++ }
        return sprintf("%.1f %s", b, u[i])
      }
      { size[NR] = $1; name[NR] = $2; total += $1 }
      END {
        printf "%-24s %12s %8s\n", "PACKAGE", "SIZE", "SHARE"
        for (i = 1; i <= NR; i++)
          printf "%-24s %12s %7.1f%%\n", name[i], human(size[i]), size[i] * 100 / total
        printf "%-24s %12s\n", "TOTAL", human(total)
      }'
