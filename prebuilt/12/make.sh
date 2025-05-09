#!/bin/bash

systempath=$1
romdir=$2
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

# Deal with non-flattened apex
$thispath/../../scripts/apex12_extractor.sh $1/apex
#$thispath/../../scripts/apex12_extractor.sh $1/system_ext/apex
echo "ro.apex.updatable=true" >> $1/product/etc/build.prop
rm -rf $1/apex/*/

# Copy system files
rsync -ra $thispath/system/ $systempath

# Overlays
if [ ! -d  $1/product ]; then
    rm -rf $1/product
    mkdir -p $1/product
fi
mkdir -p $1/product/overlay

cp -fpr $thispath/nondevice_overlay/* $1/product/overlay/

if [[ ! -f "$romdir/NODEVICEOVERLAY" ]]; then
    cp -fpr $thispath/overlay/* $1/product/overlay/
fi

cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts

# Cleanup empty selinux mappings
find $1/system_ext/etc/selinux/mapping/ -type f -empty -delete

# Disable Codec2
sed -i "s/android.hardware.media.c2/android.hardware.erfan.c2/g" $1/etc/vintf/manifest.xml
rm -rf $1/etc/vintf/manifest/manifest_media_c2_software.xml

# Fix vendor CAF sepolicies
$thispath/../../scripts/sepolicy_prop_remover.sh $1/etc/selinux/plat_property_contexts "device/qcom/sepolicy" > $1/../../plat_property_contexts
mv $1/../../plat_property_contexts $1/etc/selinux/plat_property_contexts
sed -i "/typetransition location_app/d" $1/etc/selinux/plat_sepolicy.cil

# Drop reboot_on_failure of init.rc
sed -i "/reboot_on_failure/d" $1/etc/init/hw/init.rc

# GSI always generate dex pre-opt in system image
echo "ro.cp_system_other_odex=0" >> $1/product/etc/build.prop

# GSI disables non-AOSP nnapi extensions on product partition
echo "ro.nnapi.extensions.deny_on_product=true" >> $1/product/etc/build.prop

# TODO(b/136212765): the default for LMK
echo "ro.lmk.kill_heaviest_task=true" >> $1/product/etc/build.prop
echo "ro.lmk.kill_timeout_ms=100" >> $1/product/etc/build.prop
echo "ro.lmk.use_minfree_levels=true" >> $1/product/etc/build.prop

#sudo sed -i "s|/dev/uinput               0660   uhid       uhid|/dev/uinput               0660   system     bluetooth|" $1/etc/ueventd.rc

# Disable bpfloader
rm -rf $1/etc/init/bpfloader.rc
echo "bpf.progs_loaded=1" >> $1/product/etc/build.prop

# Bypass SF validateSysprops
echo "ro.surface_flinger.vsync_event_phase_offset_ns=-1" >> $1/product/etc/build.prop
echo "ro.surface_flinger.vsync_sf_event_phase_offset_ns=-1" >> $1/product/etc/build.prop
echo "debug.sf.high_fps_late_app_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.early_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.early_gl_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.early_app_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.early_gl_app_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.high_fps_late_sf_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.high_fps_early_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.high_fps_early_gl_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.high_fps_early_app_phase_offset_ns=" >> $1/product/etc/build.prop
echo "debug.sf.high_fps_early_gl_app_phase_offset_ns=" >> $1/product/etc/build.prop

# random fix for decryption
echo "rm -rf /data/system/storage.xml" >> $1/bin/cppreopts.sh
rm -rf $1/product/etc/security/avb

# Fix dual sim issue in settings 
echo "persist.sys.fflag.override.settings_provider_model=false" >> $1/build.prop
