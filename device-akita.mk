#
# Copyright (C) 2021 The Android Open-Source Project
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

PRODUCT_RELEASE_CONFIG_MAPS += $(wildcard vendor/google_devices/release/phones/./pixel_2024_midyear/release_config_map.textproto)

TARGET_LINUX_KERNEL_VERSION := $(RELEASE_KERNEL_AKITA_VERSION)
# Keeps flexibility for kasan and ufs builds
TARGET_KERNEL_DIR ?= $(RELEASE_KERNEL_AKITA_DIR)
TARGET_BOARD_KERNEL_HEADERS ?= $(RELEASE_KERNEL_AKITA_DIR)/kernel-headers

ifneq ($(TARGET_BOOTS_16K),true)
PRODUCT_16K_DEVELOPER_OPTION := $(RELEASE_GOOGLE_AKITA_16K_DEVELOPER_OPTION)
endif

$(call inherit-product-if-exists, vendor/google_devices/akita/prebuilts/device-vendor-akita.mk)
$(call inherit-product-if-exists, vendor/google_devices/zuma/prebuilts/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/zuma/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/akita/proprietary/akita/device-vendor-akita.mk)
$(call inherit-product-if-exists, vendor/google_devices/akita/proprietary/device-vendor.mk)
$(call inherit-product-if-exists, vendor/google_devices/akita/proprietary/WallpapersAkita.mk)

DEVICE_PACKAGE_OVERLAYS += device/google/akita/akita/overlay

ifeq ($(RELEASE_PIXEL_AIDL_AUDIO_HAL_ZUMA),true)
USE_AUDIO_HAL_AIDL := true
endif

include device/google/akita/audio/akita/audio-tables.mk
include device/google/zuma/device-shipping-common.mk
include device/google/gs-common/bcmbt/bluetooth.mk
include device/google/gs-common/touch/gti/predump_gti.mk
include device/google/gs-common/modem/radio_ext/radio_ext.mk

# go/lyric-soong-variables
$(call soong_config_set,lyric,camera_hardware,akita)
$(call soong_config_set,lyric,tuning_product,akita)
$(call soong_config_set,google3a_config,target_device,akita)

# Recovery files
PRODUCT_COPY_FILES += \
        device/google/akita/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.akita.rc

PRODUCT_SOONG_NAMESPACES += device/google/akita/radio/coex

# NFC
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
	frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
	frameworks/native/data/etc/android.hardware.nfc.hcef.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hcef.xml \
	frameworks/native/data/etc/com.nxp.mifare.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.nxp.mifare.xml \
	frameworks/native/data/etc/android.hardware.nfc.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.ese.xml \

PRODUCT_PACKAGES += \
	$(RELEASE_PACKAGE_NFC_STACK) \
	Tag \
	android.hardware.nfc-service.st \
	NfcOverlayAkita

# SecureElement
PRODUCT_PACKAGES += \
	android.hardware.secure_element-service.thales

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.se.omapi.ese.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.ese.xml \
	frameworks/native/data/etc/android.hardware.se.omapi.uicc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.se.omapi.uicc.xml \

# Settings Overlay
PRODUCT_PACKAGES += \
    SettingsAkitaOverlay

# WiFi Overlay
PRODUCT_PACKAGES += \
	WifiOverlay2024Mid

# include GNSSD
include device/google/akita/location/gnssd/device-gnss.mk

# Fingerprint HAL
GOODIX_CONFIG_BUILD_VERSION := g7_trusty
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_common.mk)
ifeq ($(filter factory%, $(TARGET_PRODUCT)),)
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_shipping.mk)
else
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_factory.mk)
endif

# Vibrator HAL
$(call soong_config_set,haptics,kernel_ver,v$(subst .,_,$(TARGET_LINUX_KERNEL_VERSION)))
ADAPTIVE_HAPTICS_FEATURE := adaptive_haptics_v1
ACTUATOR_MODEL := legacy_zlra_actuator

# Set build properties for SMR builds
ifeq ($(RELEASE_IS_SMR), true)
    ifneq (,$(RELEASE_BASE_OS_AKITA))
        PRODUCT_BASE_OS := $(RELEASE_BASE_OS_AKITA)
    endif
endif

# Window Extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# ETM
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif

PRODUCT_NO_BIONIC_PAGE_SIZE_MACRO := true
PRODUCT_CHECK_PREBUILT_MAX_PAGE_SIZE := true

# Enable APF by default
PRODUCT_VENDOR_PROPERTIES += \
    vendor.powerhal.apf_disabled=false \
    vendor.powerhal.apf_enabled=true
