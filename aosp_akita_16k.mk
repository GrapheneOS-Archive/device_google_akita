$(call inherit-product, device/google/akita/aosp_akita.mk)

PRODUCT_NAME := aosp_akita_16k

TARGET_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_RW_FILE_SYSTEM_TYPE := ext4
TARGET_BOOTS_16K := true

