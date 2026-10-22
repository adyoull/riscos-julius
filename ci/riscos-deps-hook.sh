#!/bin/bash
# Run by .github/workflows/riscos-deps-update.yml when a release named in
# .riscos-deps moves:  ci/riscos-deps-hook.sh NAME OLD_TAG NEW_TAG
# (from the top of the repository, before .riscos-deps changes).
#
# riscos-mesa: build/SHA256SUMS holds the devkit's checksum, so fetch the
# new release's devkit and put its sha256 in place of the old line.
# riscos-crossdev: nothing else pins it (build/env.sh reads .riscos-deps).
set -euo pipefail
name=${1#adyoull/} old=$2 new=$3
case $name in
  riscos-mesa)
    file=riscos-mesa-devkit-${new#v}.tgz
    url=https://github.com/adyoull/riscos-mesa/releases/download/$new/$file
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL --retry 3 -o "$tmp/$file" "$url"
    sum=$(sha256sum "$tmp/$file" | cut -d' ' -f1)
    awk -v old="riscos-mesa-devkit-${old#v}.tgz" '$2 != old' build/SHA256SUMS > "$tmp/sums"
    printf '%s  %s\n' "$sum" "$file" >> "$tmp/sums"
    cat "$tmp/sums" > build/SHA256SUMS
    echo "build/SHA256SUMS: $file $sum"
    ;;
esac
