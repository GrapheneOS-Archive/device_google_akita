# Enable pixel gnss hal service
-include vendor/google/gnss/aidl_service/pixel_gnss_hal.mk

PRODUCT_PACKAGES += \
    gnssd \
    android.hardware.gnss-service \
    android.hardware.location.gps.prebuilt.xml

PRODUCT_COPY_FILES += \
    device/google/akita/location/gnssd/release/ca.pem:vendor/etc/gnss/ca.pem \
    device/google/akita/location/gnssd/release/kepler.bin:vendor/firmware/kepler.bin

PRODUCT_SOONG_NAMESPACES += \
    device/google/akita/location/gnssd

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
    PRODUCT_COPY_FILES += \
        device/google/akita/location/gnssd/release/gps.cfg:vendor/etc/gnss/gps.cfg
    PRODUCT_VENDOR_PROPERTIES += \
        vendor.gps.aol.enabled=true
else
    PRODUCT_COPY_FILES += \
        device/google/akita/location/gnssd/release/gps_user.cfg:vendor/etc/gnss/gps.cfg
endif
