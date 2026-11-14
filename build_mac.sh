#!/bin/sh
# Builds PumpkinOS on macOS. See "Building on macOS" in README.md.
#
#   ./build_mac.sh            build everything
#   ./build_mac.sh clean      remove build output
#
# Environment:
#   SDL2_CONFIG  path to sdl2-config (default: sdl2-config on PATH,
#                then ~/.local/bin/sdl2-config)
#   UNICORN      Unicorn source dir with build/libunicorn.a, needed to run
#                ARM apps (default: deps/unicorn-2.1.4 if it exists)
set -e
cd "$(dirname "$0")"

if [ -z "$SDL2_CONFIG" ]; then
  SDL2_CONFIG=$(command -v sdl2-config || true)
fi
if [ -z "$SDL2_CONFIG" ] && [ -x "$HOME/.local/bin/sdl2-config" ]; then
  SDL2_CONFIG="$HOME/.local/bin/sdl2-config"
fi
if [ -z "$SDL2_CONFIG" ] || [ ! -x "$SDL2_CONFIG" ]; then
  echo "sdl2-config not found: install SDL2 or set SDL2_CONFIG" >&2
  exit 1
fi
# the Makefiles call sdl2-config by name
PATH="$(dirname "$SDL2_CONFIG"):$PATH"
export PATH

if [ -z "$UNICORN" ] && [ -f deps/unicorn-2.1.4/build/libunicorn.a ]; then
  UNICORN="$PWD/deps/unicorn-2.1.4"
fi
if [ -n "$UNICORN" ]; then
  if [ ! -f "$UNICORN/build/libunicorn.a" ]; then
    echo "$UNICORN/build/libunicorn.a not found: build Unicorn first" >&2
    exit 1
  fi
  echo "Using SDL2 $("$SDL2_CONFIG" --version), Unicorn in $UNICORN"
  make -C src UNICORN="$UNICORN" "$@"
else
  echo "Using SDL2 $("$SDL2_CONFIG" --version), no Unicorn (ARM apps will not run)"
  make -C src "$@"
fi
