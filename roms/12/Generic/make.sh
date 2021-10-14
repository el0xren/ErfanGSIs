#!/bin/bash

# Drop some services
sed -i "/dataservice_app/d" $1/product/etc/selinux/product_seapp_contexts
sed -i "/dataservice_app/d" $1/system_ext/etc/selinux/system_ext_seapp_contexts
sed -i "/ro.sys.sdcardfs/d" $1/product/etc/build.prop

# Some addons
echo "ro.support_one_handed_mode=true" >> $1/build.prop
echo "ro.boot.vendor.overlay.theme=com.google.android.systemui.gxoverlay" >> $1/product/etc/build.prop
