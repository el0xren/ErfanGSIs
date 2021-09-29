#!/bin/bash
# Written By @nnippon!, credits for all peeps ofc
# Don't forget to give proper credits!
# Based on Erfan tools so use properly

# Define env
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
extractor="$LOCALDIR/tools/Firmware_extractor/extractor.sh"
working="$LOCALDIR/system"
outdir="$LOCALDIR/cache"

# Let's start
echo "Merging Process Started!"
echo "Initializing..."
	umount -l $working $outdir 2>/dev/null >> tmp.log
	rm -rf $working new.img $outdir
	mkdir -p "$outdir" "$working"
	bash update.sh 2>/dev/null >> tmp.log

echo "Extracting..."
	bash $extractor $1 $outdir 2>/dev/null >> tmp.log

echo "Creating temp image..."
	dd if=/dev/zero of=new.img bs=8k count=1048576 2>/dev/null >> tmp.log
	mkfs.ext4 new.img 2>/dev/null >> tmp.log
	tune2fs -c0 -i0 new.img 2>/dev/null >> tmp.log

echo "Merging Partitions..."
echo "system.img"
	mkdir $outdir/system
	mount -o loop new.img $working
	mount -o ro $outdir/system.img $outdir/system
	cp -frp $outdir/system/* $working/
	sync

if [ -f "$outdir/product.img" ]; then
echo "product.img"
	rm -rf $working/product
	rm -rf $working/system/product
	mkdir $working/system/product
	mkdir $outdir/product
	mount -o ro $outdir/product.img $outdir/product
	cp -frp $outdir/product/* $working/system/product/
	ln -s /system/product $working/product
	sync
fi

if [ -f "$outdir/system_ext.img" ]; then
echo "system_ext.img"
	mkdir $outdir/system_ext
	mount -o ro $outdir/system_ext.img $outdir/system_ext/
	rm -rf $working/system_ext
	rm -rf $working/system/system_ext
	mkdir $working/system/system_ext
	cp -frp $outdir/system_ext/* $working/system/system_ext/
	ln -s /system/system_ext $working/system_ext
	sync
fi

if [ -f "$outdir/vendor.img" ]; then
echo "vendor.img"
	mkdir $outdir/vendor
	mount -o ro $outdir/vendor.img $outdir/vendor/
	cp -frp $outdir/vendor/overlay/* $working/system/product/overlay/
	sync
fi

echo "Finalizing..."
	umount -l $outdir/* 2>/dev/null >> tmp.log
	rm -rf $outdir tmp.log

echo "Merging Process Done!"
echo "Continue using make.sh!"
# by @nnippon
