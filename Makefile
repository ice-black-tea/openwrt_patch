#!/bin/sh

CURRENT_PATH=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OPENWRT_ROOT_PATH=~/Projects/openwrt
OPENWRT_LINUX_VERSION=linux-4.14.179
OPENWRT_KERNEL_PATH=${OPENWRT_ROOT_PATH}/build_dir/target-x86_64_musl/linux-x86_64/${OPENWRT_LINUX_VERSION}
OPENWRT_CROSS_COMPILE=${OPENWRT_ROOT_PATH}/staging_dir/toolchain-x86_64_gcc-7.5.0_musl/bin/x86_64-openwrt-linux-

app:
	cd ${OPENWRT_ROOT_PATH} && ./scripts/feeds update -a && ./scripts/feeds install -a
	cd ${OPENWRT_ROOT_PATH}/package/feeds/luci && git clone https://github.com/project-openwrt/Lean-SSRPlus.git temp_packages && (cp -n -r temp_packages/* . || echo ok ) && rm -rf temp_packages
	# cd ${OPENWRT_ROOT_PATH}/package/feeds/luci && git clone https://github.com/maxlicheng/luci-app-ssr-plus.git

quectel_cm:
	cd ${CURRENT_PATH}/quectel-cm && make CROSS_COMPILE=${OPENWRT_CROSS_COMPILE}

ec20_patch:
	cp ${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/option.c ${OPENWRT_KERNEL_PATH}/drivers/usb/serial/
	cp ${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/usb_wwan.c ${OPENWRT_KERNEL_PATH}/drivers/usb/serial/
	cp ${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/qmi_wwan.c ${OPENWRT_KERNEL_PATH}/drivers/net/usb/

ec20_patch_backup:
	mkdir -p ${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/bak/
	[ ! -d "${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/bak/option.c" ] || cp ${OPENWRT_KERNEL_PATH}/drivers/usb/serial/option.c ${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/bak/
	[ ! -d "${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/bak/usb_wwan.c" ] || cp ${OPENWRT_KERNEL_PATH}/drivers/usb/serial/usb_wwan.c ${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/bak/
	[ ! -d "${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/bak/qmi_wwan.c" ] || cp ${OPENWRT_KERNEL_PATH}/drivers/net/usb/qmi_wwan.c ${CURRENT_PATH}/${OPENWRT_LINUX_VERSION}/bak/
