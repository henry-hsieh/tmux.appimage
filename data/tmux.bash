#!/bin/bash

TERMINFO_DIRS=$(dirname $(realpath $0))/../share/terminfo $(dirname $(realpath $0))/tmux $@
