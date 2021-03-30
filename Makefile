ifdef SIMULATOR
TARGET = simulator:clang:11.2:8.0
else
TARGET = iphone:clang:11.2:7.0
ARCHS= arm64 arm64e
endif

INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = ProperCCBackgroundiPad

ProperCCBackgroundiPad_FILES = Tweak.x
ProperCCBackgroundiPad_CFLAGS = -fobjc-arc -Wno-error=unused-variable -Wno-error=unused-function -include Prefix.pch

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
