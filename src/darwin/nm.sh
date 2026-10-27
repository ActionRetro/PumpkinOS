#!/bin/sh
# macOS nm prefixes C symbols with "_"; strip it so names match traps.txt.
nm -j -u "$@" | sed -e 's/^_//'
