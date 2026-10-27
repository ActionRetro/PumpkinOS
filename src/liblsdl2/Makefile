# additional package(s) to install (example for Ubuntu):
# sudo apt install libsdl2-dev

include ../common.mak

PROGRAM=liblsdl2
SOURCE=liblsdl2.c

#MIXER_LIBS=-lSDL2_mixer
#MIXER_FLAGS=-DSDL_MIXER
OPENGL_FLAGS=-DSDL_OPENGL
OPENGL_LIBS=-lGL

ifeq ($(OSNAME),Kernel)
STATIC=1
else ifeq ($(OSNAME),Emscripten)
STATIC=2
CUSTOMFLAGS=-s USE_SDL=2
else ifeq ($(OSNAME),Msys)
CUSTOMFLAGS=$(MIXER_FLAGS) $(OPENGL_FLAGS)
LIBS=-lSDL2 -lversion -limm32 -lgdi32 -lsetupapi -lwinmm -lole32 -loleaut32 $(MIXER_LIBS)
else ifeq ($(OSNAME),Darwin)
SDL_PREFIX=$(shell sdl2-config --prefix)
CUSTOMFLAGS=$(MIXER_FLAGS) $(OPENGL_FLAGS) -I$(SDL_PREFIX)/include -D_THREAD_SAFE -DGL_SILENCE_DEPRECATION
LIBS=-L$(SDL_PREFIX)/lib -lSDL2 $(MIXER_LIBS) -framework OpenGL -Wl,-rpath,$(SDL_PREFIX)/lib
else
CUSTOMFLAGS=$(MIXER_FLAGS) $(OPENGL_FLAGS)
LIBS=-lSDL2 $(MIXER_LIBS) $(OPENGL_LIBS)
endif

include ../lib.mak
