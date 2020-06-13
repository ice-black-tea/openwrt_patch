#!/bin/sh

CURRENT_PATH=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

OPENWRT_URL=https://github.com/openwrt/openwrt.git
OPENWRT_BRANCH=master
OPENWRT_LINUX_VERSION=5.4
OPENWRT_TARGET_SYSTEM=x86_64
OPENWRT_IP=192.168.6.1

OPENWRT_PATH=~/Projects/openwrt
OPENWRT_KERNEL_PATH=${OPENWRT_PATH}/build_dir/target-${OPENWRT_TARGET_SYSTEM}_musl/linux-${OPENWRT_TARGET_SYSTEM}/linux-${OPENWRT_LINUX_VERSION}*
OPENWRT_PATCH_PATH=${OPENWRT_PATH}/target/linux/generic/hack-${OPENWRT_LINUX_VERSION}

OPENWRT_SSH_HOST=root@${OPENWRT_IP}
OPENWRT_SSH_QUECTEL=/root/quectel

PATCH_PATH=${CURRENT_PATH}/patch/${OPENWRT_LINUX_VERSION}

clean:
	cd ${CURRENT_PATH}/quectel-cm && make clean
	rm -f ${CURRENT_PATH}/quectel-cm-files/quectel/quectel-CM
	rm -f ${CURRENT_PATH}/quectel-cm-files/quectel/quectel-qmi-proxy

prepare: clone ip app config_copy config download

clone:
	git clone -b ${OPENWRT_BRANCH} ${OPENWRT_URL} ${OPENWRT_PATH}

patch1:
	sed -i 's/192.168.1.1/${OPENWRT_IP}/g' ${OPENWRT_PATH}/package/base-files/files/bin/config_generate
	cp ${PATCH_PATH}/*.patch ${OPENWRT_PATH}/target/linux/generic/hack-${OPENWRT_LINUX_VERSION}/
	cd ${OPENWRT_PATH} && test -s ${PATCH_PATH}/patch.sh && bash ${PATCH_PATH}/patch.sh

config:
	cd ${OPENWRT_PATH} && make menuconfig

config_copy:
	cp ${CURRENT_PATH}/${OPENWRT_TARGET_SYSTEM}.config ${OPENWRT_PATH}/.config

config_backup:
	cp ${OPENWRT_PATH}/.config ${CURRENT_PATH}/${OPENWRT_TARGET_SYSTEM}.config

download:
	cd ${OPENWRT_PATH} && make download V=s -j4

build:
	cd ${OPENWRT_PATH} && make V=s -j1

app:
	cd ${OPENWRT_PATH} && ./scripts/feeds update -a && ./scripts/feeds install -a
	cd ${OPENWRT_PATH}/package/feeds/ && mkdir -p addition &&  cp -n -r ${CURRENT_PATH}/packages/* addition/ || true


quectel_make:
	cd ${CURRENT_PATH}/quectel-cm && make CROSS_COMPILE=`echo $(OPENWRT_PATH)/staging_dir/toolchain-*_gcc-*_musl/bin/`${OPENWRT_TARGET_SYSTEM}-openwrt-linux-

quectel_debug: quectel_make
	ssh ${OPENWRT_SSH_HOST} "rm -rf ${OPENWRT_SSH_QUECTEL}"
	cp ${CURRENT_PATH}/quectel-cm/quectel-CM ${CURRENT_PATH}/quectel-cm-files/quectel/
	cp ${CURRENT_PATH}/quectel-cm/quectel-qmi-proxy ${CURRENT_PATH}/quectel-cm-files/quectel/
	scp -r ${CURRENT_PATH}/quectel-cm-files/quectel/ ${OPENWRT_SSH_HOST}:${OPENWRT_SSH_QUECTEL}
	ssh ${OPENWRT_SSH_HOST} "${OPENWRT_SSH_QUECTEL}/quectel-CM -v"

quectel_patch:
	cd ${OPENWRT_KERNEL_PATH} && patch -p1 < ${PATCH_PATH}/999-quectel.patch

quectel_patch_make:
	cd ${PATCH_PATH}/quectel && diff -urN a b > ${PATCH_PATH}/999-quectel.patch || true

quectel_patch_backup:
	cd ${PATCH_PATH}/quectel && mkdir -p a/drivers/usb/serial/ a/drivers/net/usb/
	cd ${PATCH_PATH}/quectel && (test -s "a/drivers/usb/serial/option.c" || cp ${OPENWRT_KERNEL_PATH}/drivers/usb/serial/option.c a/drivers/usb/serial/)
	cd ${PATCH_PATH}/quectel && (test -s "a/drivers/usb/serial/usb_wwan.c" || cp ${OPENWRT_KERNEL_PATH}/drivers/usb/serial/usb_wwan.c a/drivers/usb/serial/)
	cd ${PATCH_PATH}/quectel && (test -s "a/drivers/net/usb/qmi_wwan.c" || cp ${OPENWRT_KERNEL_PATH}/drivers/net/usb/qmi_wwan.c a/drivers/net/usb/)
	cd ${PATCH_PATH}/quectel && (test -s "b" || cp -r a b)

quectel_patch_restore:
	cd ${PATCH_PATH}/quectel && (test -s "a/drivers/usb/serial/option.c" && cp a/drivers/usb/serial/option.c ${OPENWRT_KERNEL_PATH}/drivers/usb/serial/)
	cd ${PATCH_PATH}/quectel && (test -s "a/drivers/usb/serial/usb_wwan.c" && cp a/drivers/usb/serial/usb_wwan.c ${OPENWRT_KERNEL_PATH}/drivers/usb/serial/)
	cd ${PATCH_PATH}/quectel && (test -s "a/drivers/net/usb/qmi_wwan.c" && cp a/drivers/net/usb/qmi_wwan.c ${OPENWRT_KERNEL_PATH}/drivers/net/usb/)
