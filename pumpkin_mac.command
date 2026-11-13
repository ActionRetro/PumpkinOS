#!/bin/sh
# macOS launcher. Runs fullscreen by default (Cmd+Q to quit).
# Use "./pumpkin_mac.command --window" to start in a 704x416 window instead.
# The green titlebar button toggles fullscreen either way.
cd "$(dirname "$0")"
if [ "$1" = "--window" ]; then
  export PUMPKIN_WINDOWED=1
fi
export PATH=./bin:$PATH
export DYLD_LIBRARY_PATH=./bin
./pumpkin -d 1 -f pumpkin.log -s libscriptlua ./script/pumpkin_mac.lua
