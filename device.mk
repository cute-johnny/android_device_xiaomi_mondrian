#
# Copyright (C) 2022-2023 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from xiaomi sm8450-common
TARGET_HAS_UDFPS := true
$(call inherit-product, device/xiaomi/sm8450-common/common.mk)

# Inherit from the proprietary version
$(call inherit-product, vendor/xiaomi/mondrian/mondrian-vendor.mk)

# Audio
PRODUCT_PACKAGES += \
    firmware_aw_cali.bin_symlink

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio/mixer_paths_waipio_mtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/mixer_paths_waipio_mtp.xml \
    $(LOCAL_PATH)/audio/resourcemanager_waipio_mtp.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio/sku_cape/resourcemanager_waipio_mtp.xml \
    $(LOCAL_PATH)/audio/usecaseKvManager.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usecaseKvManager.xml

# Overlay
PRODUCT_PACKAGES += \
    ApertureResMondrian \
    FrameworksResMondrian \
    FrameworksResMondrianGlobal \
    LineageResMondrian \
    NfcResMondrian \
    SettingsProviderResMondrian \
    SettingsProviderResMondrianCN \
    SettingsResMondrian \
    SystemUIResMondrian \
    WifiResMondrian \
    WifiResMondrianCN

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# System properties
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/properties/build_CN.prop:$(TARGET_COPY_OUT_ODM)/etc/build_CN.prop \
    $(LOCAL_PATH)/properties/build_GL.prop:$(TARGET_COPY_OUT_ODM)/etc/build_GL.prop

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/properties/build_CN.prop:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/odm/etc/build_CN.prop \
    $(LOCAL_PATH)/properties/build_GL.prop:$(TARGET_COPY_OUT_RECOVERY)/root/vendor/odm/etc/build_GL.prop

# Vibrator
$(call soong_config_set,qti_vibrator,effect_lib,libqtivibratoreffect.xiaomi)
$(call soong_config_set_bool,qti_vibrator,use_effect_stream,true)

# Dolby compatibility matrix
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    hardware/dolby/dolby_framework_matrix.xml

# Call the MiuiCamera setup
$(call inherit-product-if-exists, device/xiaomi/miuicamera-mondrian/device.mk)


# Memory Management (Android 17 mmd ZRAM + LMKD tuning)
PRODUCT_VENDOR_PROPERTIES += \
    mmd.zram.enabled=true \
    mmd.zram.comp_algorithm=lz4 \
    mmd.zram.size=75% \
    mmd.zram.writeback.enabled=true \
    mmd.zram.writeback.device_size=1073741824 \
    mmd.zram.writeback.min_free_space_mib=2048 \
    mmd.zram.writeback.idle.enabled=true \
    mmd.zram.writeback.huge_idle.enabled=true

PRODUCT_PRODUCT_PROPERTIES += \
    ro.lmk.kill_heaviest_task=true \
    ro.lmk.psi_partial_stall_ms=100 \
    ro.lmk.thrashing_limit=100 \
    ro.lmk.swap_free_low_percentage=10

# mmd: sepolicy gives mmd no sysfs read for /sys/class/block/*/mq/0/nr_tags, so
# provide the UFS queue depth (32 slots - 1 reserved, ufshcd.c) via props.
PRODUCT_VENDOR_PROPERTIES += \
    mmd.zram.writeback.use_nr_tags_prop=true \
    mmd.zram.writeback.nr_tags=31

PRODUCT_PRODUCT_PROPERTIES += \
    ro.lmk.kill_timeout_ms=100

# RisingOS spoofer strictly opt-in (TEESimulator/AlwaysStrong owns attestation).
# Re-enable: settings put secure spoof_activated 1
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.spoof.auto_activate=false

# MemoryLimiter: per-app cgroup v2 memory.high / swap limits (per RAM tier)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/memory-limiter-config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/memory-limiter-config.xml

# mmd: recompress idle/huge zram pages with zstd (kernel CONFIG_ZRAM_MULTI_COMP)
PRODUCT_VENDOR_PROPERTIES += \
    mmd.zram.recompression.enabled=true \
    mmd.zram.recompression.algorithm=zstd

# logd: 8 MiB per log buffer (default 256 KiB keeps only ~40 min of history)
PRODUCT_VENDOR_PROPERTIES += \
    ro.logd.size=8M
