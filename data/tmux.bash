#!/usr/bin/env bash

APPIMAGE_DIR=$(dirname $(realpath $0))
TERMINFO_DIRS=${APPIMAGE_DIR}/usr/share/terminfo${TERMINFO_DIRS:+:$TERMINFO_DIRS} \
PATH=${APPIMAGE_DIR}/usr/bin${PATH:+:$PATH} \
${APPIMAGE_DIR}/usr/bin/tmux "$@"
