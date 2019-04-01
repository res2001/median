uname_S := $(shell uname -s)
uname_M := $(shell uname -m)

ifeq (MINGW,$(findstring MINGW,$(uname_S)))
  PLATFORM := MINGW
  ifeq (MINGW64,$(findstring MINGW64,$(uname_S)))
    ARCH := x64
  else
    ARCH := x32
  endif
else
  ifeq ($(uname_S), Linux)
    PLATFORM := Linux
    ifeq (x86_64,$(uname_M))
      ARCH := x64
    else
      ifeq (i686,$(uname_M))
        ARCH := x32
      else
        $(error Unknown CPU architecture.)
      endif
    endif
  else
        $(error Unknown OS.)
  endif
endif
