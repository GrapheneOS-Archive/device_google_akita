#
# Copyright (C) 2020 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Enable load module in parallel
BOARD_BOOTCONFIG += androidboot.load_modules_parallel=true

# The modules which need to be loaded in sequential
BOARD_KERNEL_CMDLINE += fips140.load_sequential=1
BOARD_KERNEL_CMDLINE += exynos_drm.load_sequential=1
BOARD_KERNEL_CMDLINE += g2d.load_sequential=1
BOARD_KERNEL_CMDLINE += samsung_iommu_v9.load_sequential=1

RELEASE_GOOGLE_PRODUCT_RADIO_DIR := $(RELEASE_GOOGLE_AKITA_RADIO_DIR)
RELEASE_GOOGLE_PRODUCT_RADIOCFG_DIR := $(RELEASE_GOOGLE_AKITA_RADIOCFG_DIR)

TARGET_BOARD_INFO_FILE := device/google/akita/board-info.txt
TARGET_BOOTLOADER_BOARD_NAME := akita
RELEASE_GOOGLE_BOOTLOADER_AKITA_DIR ?= pdk# Keep this for pdk TODO: b/327119000
RELEASE_GOOGLE_PRODUCT_BOOTLOADER_DIR := bootloader/$(RELEASE_GOOGLE_BOOTLOADER_AKITA_DIR)
$(call soong_config_set,akita_bootloader,prebuilt_dir,$(RELEASE_GOOGLE_BOOTLOADER_AKITA_DIR))
TARGET_SCREEN_DENSITY := 420
BOARD_USES_GENERIC_AUDIO := true
USES_DEVICE_GOOGLE_AKITA := true
BOARD_KERNEL_CMDLINE += swiotlb=noforce
BOARD_KERNEL_CMDLINE += disable_dma32=on

include device/google/zuma/BoardConfig-common.mk
-include vendor/google_devices/zuma/prebuilts/BoardConfigVendor.mk
include device/google/gs-common/check_current_prebuilt/check_current_prebuilt.mk
-include vendor/google_devices/akita/proprietary/BoardConfigVendor.mk
include device/google/akita-sepolicy/akita-sepolicy.mk
include device/google/akita/wifi/BoardConfig-wifi.mk

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
-include device/google/common/etm/5_15/BoardUserdebugModules.mk
endif
