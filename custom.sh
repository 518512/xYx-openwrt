#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

function merge_package(){
    repo=`echo $1 | rev | cut -d'/' -f 1 | rev`
    pkg=`echo $2 | rev | cut -d'/' -f 1 | rev`
    git clone --depth=1 --single-branch $1
    mv $2 package/custom/
    rm -rf $repo
}
function drop_package(){
    find package/ -follow -name $1 -not -path "package/custom/*" | xargs -rt rm -rf
}
function merge_feed(){
    if [ ! -d "feed/$1" ]; then
        echo >> feeds.conf.default
        echo "src-git $1 $2" >> feeds.conf.default
    fi
    ./scripts/feeds update $1
    ./scripts/feeds install -a -p $1
}
rm -rf package/custom; mkdir package/custom

# Modify default IP
sed -i 's/192.168.1.1/10.5.2.1/g' package/base-files/files/bin/config_generate
 
# add custom packages
# echo 'src-git xYx https://github.com/xYx-c/openwrt-luci' >>feeds.conf.default

# openclash packages
git clone --depth=1 -b master https://github.com/vernesong/OpenClash.git openclash
mv openclash/luci-app-openclash package/luci-app-openclash && rm -rf openclash

git clone --depth=1 -b master https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome

git clone --depth=1 -b main https://github.com/kingyond/luci-app-accesscontrol-plus accesscontrol-plus
mv accesscontrol-plus/luci-app-accesscontrol-plus  package/luci-app-accesscontrol-plus && rm -rf accesscontrol-plus

git clone --depth=1 -b master https://github.com/rufengsuixing/luci-app-zerotier package/luci-app-zerotier

#主题
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/kenzo/luci-app-argon-config
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git feeds/luci/applications/luci-app-argon-config

rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/kenzo/luci-theme-argon
git clone -b 18.06 https://github.com/SpeedPartner/luci-theme-argon-18.06-patch.git feeds/luci/themes/luci-theme-argon
sed -i '41,59d' feeds/luci/themes/luci-theme-argon/luasrc/view/themes/argon/footer.htm
# git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon

#mosdns
rm -rf feeds/kenzo/luci-app-mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
merge_package https://github.com/sbwml/luci-app-mosdns luci-app-mosdns
merge_package https://github.com/sbwml/luci-app-mosdns luci-app-mosdns/mosdns

# update golang
# pushd feeds/packages/lang
# rm -rf golang && svn co https://github.com/openwrt/packages/trunk/lang/golang
# popd
