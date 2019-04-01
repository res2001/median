.PHONY: all clean cleanobj
include platform.mk
$(info Make under $(PLATFORM) $(ARCH))

BASE_DIR ?= .
BUILD_DIR ?= $(BASE_DIR)/build
ifeq ($(PLATFORM),MINGW)
  BUILD_DIR := $(BUILD_DIR)/$(MSYSTEM)
endif
# release | debug
TYPEBUILD ?= release

TARGET_DIR := $(BUILD_DIR)/bin
SRC_DIR := $(BASE_DIR)/src
DEPS_DIR := $(BASE_DIR)/deps
OBJ_DIR := $(BUILD_DIR)/obj

TARGET := $(TARGET_DIR)/median

SRC := $(wildcard $(SRC_DIR)/*.c)

OBJS := $(SRC:.c=.o)
OBJS := $(subst $(BASE_DIR)/,$(OBJ_DIR)/,$(OBJS))
DEPS := $(OBJS:.o=.d)

CFLAGS += -std=gnu11
ifeq ($(PLATFORM),MINGW)
  TARGET_EXT := .exe
# __USE_MINGW_ANSI_STDIO - for snprintf/printf: https://sourceforge.net/p/mingw-w64/mailman/message/31241434/ 
# _USE_MATH_DEFINES - for M_PI in mingw
  CFLAGS += -D__USE_MINGW_ANSI_STDIO=0 -D_USE_MATH_DEFINES
else
  ifeq ($(PLATFORM), Linux)
# __USE_MISC - for M_PI
    CFLAGS += -D__USE_MISC -D__USE_XOPEN
  endif
endif
$(info Target: $(TARGET)$(TARGET_EXT))

#Нормальный уровень предупреждений
WARNNORMALOPTS := -Wall -Wextra -pedantic -Wno-missing-field-initializers -Wno-pedantic-ms-format -Wno-ignored-qualifiers\
                 -Werror=implicit-int -Werror=implicit-function-declaration -Werror=return-type\
                 -Wformat-security -Winit-self -Wstrict-aliasing -Wundef \
                 -Wcast-align -Wwrite-strings -Wlogical-op -Waggregate-return -Wno-format-zero-length -Wshadow
# 

#повышенный уроень предупреждения компилятора
WARNEXTRAOPTS := -Wunsafe-loop-optimizations -Winline -Werror=strict-prototypes
# -Wfloat-equal

ifeq ($(TYPEBUILD), release)
  CFLAGS += -O2 -mavx2 -mfpmath=sse
else
  CFLAGS += -g -O0 -mavx2 -mfpmath=sse -fno-inline -fno-omit-frame-pointer
endif

CFLAGS += $(WARNNORMALOPTS) $(WARNEXTRAOPTS) -I$(SRC_DIR) 
  
DEPFLAGS = -MMD -MP -MF $(OBJ_DIR)/$*.d

define target_pre_cmd
  echo ""
  echo Make $@
  echo $^ 
  @mkdir -p $(dir $@)
endef

get-lib-name = $(subst lib,,$(notdir $(basename $1)))

all: $(TARGET)$(TARGET_EXT)

cleanobj:
	@$(RM) -f $(OBJS) $(DEPS) $(THIRDLIB_OBJS) $(THIRDLIB_DEPS) 

clean: cleanobj
	@$(RM) -f $(TARGET)$(TARGET_EXT)

$(TARGET)$(TARGET_EXT): $(OBJS) $(THIRDLIB_OBJS)
	@$(target_pre_cmd)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(OBJ_DIR)/%.o: $(BASE_DIR)/%.c
$(OBJ_DIR)/%.o: $(BASE_DIR)/%.c $(OBJ_DIR)/%.d
	@$(target_pre_cmd)
	$(CC) $(DEPFLAGS) $(CFLAGS) -c -o $@ $<

$(OBJ_DIR)/%.d: ;
.PRECIOUS: $(OBJ_DIR)/%.d

include $(DEPS)
