#!/usr/bin/env bash

tmux=""
version=""
if [[ $# -eq 2 ]]; then
  tmux="$(realpath $1)"
  version="$2"
else
  echo "Usage: $0 /path/to/tmux.appimage version"
  exit 1
fi

if ! $($tmux --appimage-help >/dev/null 2>&1); then
  echo "$tmux is not an AppImage"
  exit 2
fi

appimage_version=$($tmux -V)
fail=$?

if [ $fail -ne 0 ]; then
  cd $(dirname "$tmux")
  ./$(basename $tmux) --appimage-extract
  appimage_version=$(./squashfs-root/AppRun -V)
fi

if [[ "$appimage_version" != "tmux $version" ]]; then
  echo "$tmux has version info: $appimage_version, expected: tmux $version"
  exit 3
fi

$tmux new-session ';' detach ';' kill-server
fail=$?

if [ $fail -ne 0 ]; then
  ./squashfs-root/AppRun new-session ';' detach ';' kill-server
  fail=$?
fi

if [ $fail -ne 0 ]; then
  echo "$tmux test failed"
  exit 4
fi
