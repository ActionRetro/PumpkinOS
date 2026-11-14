function cleanup_callback()
  if pumpkin then
    pumpkin.finish()
  end
end

pit.cleanup(cleanup_callback)

-- macOS: SDL2 is the only display backend
lib = pit.loadlib("liblsdl2")

if not lib then
  print("could not load liblsdl2 (was PumpkinOS built with build_mac.sh?)")
  pit.finish(0)
  return
end

-- macOS: SDL uses Metal, whose back buffers are not preserved between
-- presents, so partial redraws flicker in and out. Always redraw everything.
fullrefresh = true

pit.mount("./vfs/", "/")

pumpkin = pit.loadlib("libos")
pumpkin.init()

-- macOS: starts as a 704x416 window (fits a 720x480 screen) and, unless
-- PUMPKIN_WINDOWED is set, switches to native fullscreen right away.
-- The desktop follows the window size (green button, dragging the corner).
windowed = pit.getenv("PUMPKIN_WINDOWED")

pumpkin.start {
  density  = 144,
  width    = 704,
  height   = 416,
  fullscreen = not windowed,
  fullrefresh = fullrefresh,
  depth    = 16,
  hdepth   = lib.hdepth
}
