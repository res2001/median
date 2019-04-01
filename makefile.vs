BASE_DIR 		= .
DEPS_DIR 		= $(BASE_DIR)/deps
!IF "$(VSCMD_ARG_TGT_ARCH)"=="X64" || "$(VSCMD_ARG_TGT_ARCH)"=="x64"
BUILD_DIR 	= $(BASE_DIR)/build/x64
!ELSE
BUILD_DIR 	= $(BASE_DIR)/build/win32
!ENDIF
TARGET_DIR 	= $(BUILD_DIR)/bin
OBJ_DIR 	= $(BUILD_DIR)/obj

TARGET		= $(TARGET_DIR)/median.exe

#debug | release
TYPEBUILD = release

SRC = ./src/*.c
	  
!IF "$(TYPEBUILD)"==""
TYPEBUILD=release
!ENDIF

!IF "$(TYPEBUILD)"=="release"
CFLAGS = $(CFLAGS) /O2 /Oi /Ot /fp:fast /Gw /Gy /GR- /GS- /MT
LDFLAGS = $(LDFLAGS) /release
!ELSE
CFLAGS = $(CFLAGS) /Od /Zi /EHsc /Ob0 /Oy- /FC /MTd
LDFLAGS = $(LDFLAGS) /debug
!ENDIF

CFLAGS = $(CFLAGS) /nologo /W3 /TC /I$(BASE_DIR)/src /D_USE_MATH_DEFINES /D_CRT_SECURE_NO_WARNINGS

LDFLAGS = $(LDFLAGS) /INCREMENTAL:NO /NOLOGO /MANIFEST /MANIFESTUAC:"level='asInvoker' uiAccess='false'" /manifest:embed

!IF "$(VSCMD_ARG_TGT_ARCH)"=="X64" || "$(VSCMD_ARG_TGT_ARCH)"=="x64"
CFLAGS = $(CFLAGS) /arch:AVX2
LDFLAGS = $(LDFLAGS) /opt:ref,icf /subsystem:console,5.02 /MACHINE:X64
OBJS = $(SRC:./=./build/x64/obj/)
!ELSE
CFLAGS = $(CFLAGS) /arch:SSE2
LDFLAGS = $(LDFLAGS) /opt:ref /subsystem:console,5.01 /MACHINE:X86
OBJS = $(SRC:./=./build/win32/obj/)
!ENDIF

OBJS = $(OBJS:.c=.obj)

all: $(TARGET)

$(TARGET): $(OBJS) $(THIRDLIB_OBJS) $(LDADD)
	- @md "$(TARGET_DIR)" 1>nul 2>&1
	link /OUT:$@ $(LDFLAGS) $**

{$(BASE_DIR)/src/}.C{$(OBJ_DIR)/src/}.obj::
	- @md "$(OBJ_DIR)/src/" 1>nul 2>&1
	$(CC) /MP $(CFLAGS) /Fo$(OBJ_DIR)/src/ /c $<

cleanobj:
	- del /f /q $(OBJS:/=\) $(THIRDLIB_OBJS:/=\)

clean: cleanobj
	- del /f /q "$(TARGET:/=\)"
