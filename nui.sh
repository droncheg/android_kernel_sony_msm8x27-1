#!/bin/bash

######################################################
#                                                    #
#              NUI Kernel build script               #
#                                                    #
#                  By ngxson (Nui)                   #
#                                                    #
######################################################

######## Tunable
GCC_TOOLCHAIN=Toolchain-architoolchain-5.2-arm-linux-gnueabihf
GCC_PREFIX=arm-architoolchain-linux-gnueabihf
########

rm "/home/$USER/out/arch/arm/boot/zImage"

if [ ! -d "/home/$USER/out" ]; then
	mkdir "/home/$USER/out"
fi

export ARCH=arm
export CROSS_COMPILE="/home/$USER/$GCC_TOOLCHAIN/bin/$GCC_PREFIX-"

#make the zImage
make O="/home/$USER/out" cyanogenmod_nicki_defconfig
make O="/home/$USER/out" -j2

MODULES_DIR="/home/$USER/modules"
OUT_DIR="/home/$USER/out"

if [ -a "/home/$USER/out/arch/arm/boot/zImage" ]; then
	rm -rf $MODULES_DIR
	mkdir $MODULES_DIR
	cd $OUT_DIR
	find . -name '*.ko' -exec cp {} $MODULES_DIR/ \;
	cd $MODULES_DIR
	/home/$USER/$GCC_TOOLCHAIN/bin/$GCC_PREFIX-strip --strip-unneeded *.ko
	cd "/home/$USER/nuik"
	
	#now make boot.img
	ZIMAGE_DIR="/home/$USER/out/arch/arm/boot/zImage"
	RAMDISK_DIR="/home/$USER/nuik/ramdisk.tar.gz"
	BOOTIMG_OUT_DIR="/home/$USER/nui.img"
	BOOTIMG_BK_DIR="/home/$USER/nui_backup.img"
	BOARD_KERNEL_CMDLINE="panic=3 console=ttyHSL0,115200,n8 androidboot.hardware=qcom user_debug=23 msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.bootdevice=msm_sdcc.1 androidboot.selinux=permissive"
	
	mv "$BOOTIMG_OUT_DIR" "$BOOTIMG_BK_DIR"
	
	/home/$USER/nuik/mkbootimg --kernel "$ZIMAGE_DIR" --ramdisk "$RAMDISK_DIR" --board "" \
		--cmdline "$BOARD_KERNEL_CMDLINE" --base 0x80200000 --pagesize 4096 \
		--ramdisk_offset 0x02000000 --output "$BOOTIMG_OUT_DIR"	
else
	echo "Failed!"
fi
