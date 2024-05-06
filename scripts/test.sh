#!/usr/bin/env bash

root_dir=$(dirname $(dirname $(realpath $0)))

install='echo ""'
if [[ "$1" == "fedora:latest" ]]; then
  install='dnf install util-linux -y'
fi
docker run --rm -v $root_dir:$root_dir -w $root_dir $1 bash -c "$install; script -q -e -c \"TERM=tmux-256color ./scripts/test_tmux.sh ./build/Tmux-x86_64.AppImage $(cat $root_dir/packages/tmux.yaml | grep version | sed 's/.\+:\s//g')\" /dev/null"
