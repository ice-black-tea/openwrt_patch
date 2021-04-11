#!/bin/sh

wget --no-check-certificate -N -P target/linux/generic/hack-5.4/ https://raw.githubusercontent.com/project-openwrt/openwrt/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
wget --no-check-certificate -N -P target/linux/generic/hack-5.4/ https://raw.githubusercontent.com/project-openwrt/openwrt/master/target/linux/generic/hack-5.4/999-thermal-tristate.patch
wget --no-check-certificate -N -P target/linux/generic/pending-5.4/ https://raw.githubusercontent.com/project-openwrt/openwrt/master/target/linux/generic/pending-5.4/601-add-kernel-imq-support.patch
rm -f ./target/linux/generic/config-5.4
wget --no-check-certificate -N -P ./target/linux/generic/ https://raw.githubusercontent.com/zxlhhyccc/acc-imq-bbr/master/master/target/linux/generic/config-5.4
