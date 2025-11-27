#!/usr/bin/env bash

if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 <package> <version> <build_dir>"
  exit 1
fi
# Patch packages for specific versions

scripts_dir="$(dirname $(realpath $0))"
package="$1"
version="$2"
build_dir="$3"

if [[ "$package" == "tmux" ]] && [[ "$version" == "3.6" ]] ; then
  patch -p1 -i $scripts_dir/patch/tmux-3.6.patch
fi

if [[ "$package" == "libevent" && "$version" == "2.1.11-stable" ]] ; then
  echo "Patch $package-$version"
  patch -p1 -i $scripts_dir/patch/libevent-2.1.11-stable.patch
fi
