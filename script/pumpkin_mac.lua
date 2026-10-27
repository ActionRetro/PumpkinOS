function cleanup_callback()
  if pumpkin then
    pumpkin.finish()
  end
end

pit.cleanup(cleanup_callback)

abgr = false

if custom_load then
  lib = custom_load()
end

if not lib and pit.getenv("WAYLAND_DISPLAY") then
  lib = pit.loadlib("libwwayland")
  if lib then pit.loadlib("libaalsa") end
end

if not lib then
  lib = pit.loadlib("libray")
  if lib then
    pit.loadlib("libaalsa")
    abgr = true
  end
end

if not lib and pit.getenv("DISPLAY") then
  lib = pit.loadlib("libwxcb")
  if lib then pit.loadlib("libaalsa") end
end

if not lib then
  lib = pit.loadlib("liblsdl3")
end

if not lib then
  lib = pit.loadlib("liblsdl2")
end

if not lib then
  lib = pit.loadlib("libfb")
  if lib then
    lib.setup(0, 1, 0)
    lib.cursor(true)
  end
end

if not lib then
  lib = pit.loadlib("libwnull")
  lib.accept(true, 7000)
  --lib.connect("127.0.0.1", 7000)
end

if not lib then
  print("could not load a display lib")
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
  abgr     = abgr,
  fullrefresh = fullrefresh,
  depth    = 16,
  hdepth   = lib.hdepth
}
