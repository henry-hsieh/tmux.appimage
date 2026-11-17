#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 /path/to/tmux.appimage version" >&2
  exit 1
fi

appimage=$(realpath "$1")
version=$2
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

cd "$workdir"
"$appimage" --appimage-extract >/dev/null
appdir="$workdir/squashfs-root"
libdir="$appdir/usr/lib"

for executable in tmux tput; do
  binary="$appdir/usr/bin/$executable"
  echo "Checking runtime paths for $executable"
  readelf -d "$binary" | grep -E '(RPATH|RUNPATH)' | grep -F '$ORIGIN/../lib' >/dev/null || {
    echo "$executable is missing the relative runtime library path" >&2
    exit 1
  }

  dependencies=$(env -u LD_LIBRARY_PATH -u LD_PRELOAD ldd "$binary")
  echo "$dependencies"
  if [[ "$dependencies" == *'not found'* ]]; then
    echo "$executable has unresolved dependencies" >&2
    exit 1
  fi

  while read -r name arrow resolved _; do
    if [[ "$arrow" == '=>' && -e "$libdir/$name" ]]; then
      if [[ ! -e "$resolved" || "$(realpath "$resolved")" != "$(realpath "$libdir/$name")" ]]; then
        echo "$executable resolved bundled library $name outside the AppImage: $resolved" >&2
        exit 1
      fi
    fi
  done <<< "$dependencies"
done

actual=$(env -u LD_LIBRARY_PATH -u LD_PRELOAD "$appdir/usr/bin/tmux" -V)
if [[ "$actual" != "tmux $version" ]]; then
  echo "Expected tmux $version, got: $actual" >&2
  exit 1
fi
env -u LD_LIBRARY_PATH -u LD_PRELOAD "$appdir/usr/bin/tput" -V
