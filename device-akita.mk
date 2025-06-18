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

# Keymaster HAL
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# Gatekeeper HAL
#LOCAL_GATEKEEPER_PRODUCT_PACKAGE ?= android.hardware.gatekeeper@1.0-service.software


# Gatekeeper
# PRODUCT_PACKAGES += \
# 	android.hardware.gatekeeper@1.0-service.software

# Keymint replaces Keymaster
# PRODUCT_PACKAGES += \
# 	android.hardware.security.keymint-service

# Keymaster
#PRODUCT_PACKAGES += \
#	android.hardware.keymaster@4.0-impl \
#	android.hardware.keymaster@4.0-service

#PRODUCT_PACKAGES += android.hardware.keymaster@4.0-service.remote
#PRODUCT_PACKAGES += android.hardware.keymaster@4.1-service.remote
#LOCAL_KEYMASTER_PRODUCT_PACKAGE := android.hardware.keymaster@4.1-service
#LOCAL_KEYMASTER_PRODUCT_PACKAGE ?= android.hardware.keymaster@4.1-service

# PRODUCT_PROPERTY_OVERRIDES += \
# 	ro.hardware.keystore_desede=true \
# 	ro.hardware.keystore=software \
# 	ro.hardware.gatekeeper=software

# WiFi Overlay
PRODUCT_PACKAGES += \
	WifiOverlay2024Mid

# Trusty liboemcrypto.so
PRODUCT_SOONG_NAMESPACES += vendor/google_devices/akita/prebuilts

# include GNSSD
include device/google/akita/location/gnssd/device-gnss.mk

# Set zram size
PRODUCT_VENDOR_PROPERTIES += \
	vendor.zram.size=50p \
	persist.device_config.configuration.disable_rescue_party=true

# Increase thread priority for nodes stop
PRODUCT_VENDOR_PROPERTIES += \
	persist.vendor.camera.increase_thread_priority_nodes_stop=true

# Fingerprint HAL
GOODIX_CONFIG_BUILD_VERSION := g7_trusty
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_common.mk)
ifeq ($(filter factory%, $(TARGET_PRODUCT)),)
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_shipping.mk)
else
$(call inherit-product-if-exists, vendor/goodix/udfps/configuration/udfps_factory.mk)
endif

# Display
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += vendor.display.lbe.supported=1
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.surface_flinger.set_idle_timer_ms=1500
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.primarydisplay.google-ak3b.temperature_path=/dev/thermal/tz-by-name/display_therm/temp
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.vendor.display.read_temp_interval=30

PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.udfps.als_feed_forward_supported=true \
    persist.vendor.udfps.lhbm_controlled_in_hal_supported=true

# Fingerprint exposure compensation
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.udfps.auto_exposure_compensation_supported=true

# OIS with system imu
PRODUCT_VENDOR_PROPERTIES += \
    persist.vendor.camera.ois_with_system_imu=true

# Vibrator HAL
$(call soong_config_set,haptics,kernel_ver,v$(subst .,_,$(TARGET_LINUX_KERNEL_VERSION)))
ADAPTIVE_HAPTICS_FEATURE := adaptive_haptics_v1
ACTUATOR_MODEL := legacy_zlra_actuator
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.vibrator.hal.f0.comp.enabled=1 \
    ro.vendor.vibrator.hal.redc.comp.enabled=0 \
	persist.vendor.vibrator.hal.context.enable=false \
	persist.vendor.vibrator.hal.context.scale=40 \
	persist.vendor.vibrator.hal.context.fade=true \
	persist.vendor.vibrator.hal.context.cooldowntime=1600 \
	persist.vendor.vibrator.hal.context.settlingtime=5000

# Override Output Distortion Gain
PRODUCT_VENDOR_PROPERTIES += \
    vendor.audio.hapticgenerator.distortion.output.gain=0.29

# Increment the SVN for any official public releases
ifdef RELEASE_SVN_AKITA
TARGET_SVN ?= $(RELEASE_SVN_AKITA)
else
# Set this for older releases that don't use build flag
TARGET_SVN ?= 21
endif

PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.build.svn=$(TARGET_SVN)

# Set device family property for SMR
PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.device_family=HK3SB3AK3

# Set build properties for SMR builds
ifeq ($(RELEASE_IS_SMR), true)
    ifneq (,$(RELEASE_BASE_OS_AKITA))
        PRODUCT_BASE_OS := $(RELEASE_BASE_OS_AKITA)
    endif
endif

# Set build properties for EMR builds
ifeq ($(RELEASE_IS_EMR), true)
    ifneq (,$(RELEASE_BASE_OS_AKITA))
        PRODUCT_PROPERTY_OVERRIDES += \
        ro.build.version.emergency_base_os=$(RELEASE_BASE_OS_AKITA)
    endif
endif

# Keyboard height ratio and bottom padding in dp for portrait mode
PRODUCT_PRODUCT_PROPERTIES += \
          ro.com.google.ime.kb_pad_port_b=4.19 \
          ro.com.google.ime.height_ratio=1.1

# Enable DeviceAsWebcam support
PRODUCT_VENDOR_PROPERTIES += \
    ro.usb.uvc.enabled=true

# Window Extensions
$(call inherit-product, $(SRC_TARGET_DIR)/product/window_extensions.mk)

# Disable Settings large-screen optimization enabled by Window Extensions
PRODUCT_SYSTEM_PROPERTIES += \
    persist.settings.large_screen_opt.enabled=false

# ETM
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
$(call inherit-product-if-exists, device/google/common/etm/device-userdebug-modules.mk)
endif

PRODUCT_NO_BIONIC_PAGE_SIZE_MACRO := true
PRODUCT_CHECK_PREBUILT_MAX_PAGE_SIZE := true

# Bluetooth device id
# Akita: 0x410F
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.device_id.product_id=16655

# Set support for LEA multicodec
PRODUCT_PRODUCT_PROPERTIES += \
    bluetooth.core.le_audio.codec_extension_aidl.enabled=true

# Enable APF by default
PRODUCT_VENDOR_PROPERTIES += \
    vendor.powerhal.apf_disabled=false \
    vendor.powerhal.apf_enabled=true

# sysconfigs from stock OS
PRODUCT_COPY_FILES += \
    device/google/akita/product-sysconfig-stock.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/sysconfig/product-sysconfig-stock.xml

PRODUCT_VENDOR_PROPERTIES := $(filter-out ro.vendor.build.svn=% , $(PRODUCT_VENDOR_PROPERTIES))
