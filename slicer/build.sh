#!/usr/bin/env bash
# Builds the slicer image rebel-slicer:<hash> (the CAD server looks for exactly that tag: the hash of this directory's
# Dockerfile, slice.sh and VERSION). Downloads Bambu Studio's official AppImage once into .cache/ and checks its
# sha256 against VERSION before anything uses it.
#
#   services/slicer/build.sh          build (prints the tag)
#   services/slicer/build.sh --tag    print the tag only
set -euo pipefail
cd "$(dirname "$0")"
tag="rebel-slicer:$(cat Dockerfile slice.sh VERSION | sha256sum | cut -c1-12)"
[[ "${1:-}" == "--tag" ]] && { echo "$tag"; exit 0; }
url=$(awk '$1=="url"{print $2}' VERSION)
sum=$(awk '$1=="sha256"{print $2}' VERSION)
img=.cache/BambuStudio-24.04.AppImage
mkdir -p .cache
if [[ ! -f "$img" ]] || ! echo "$sum  $img" | sha256sum -c --quiet 2>/dev/null; then
    echo "downloading $url"
    curl -fL --retry 3 -o "$img.part" "$url"
    echo "$sum  $img.part" | sha256sum -c --quiet || { echo "sha256 mismatch: not using the download" >&2; rm -f "$img.part"; exit 1; }
    mv "$img.part" "$img"
fi
docker build -t "$tag" .
echo "$tag"
