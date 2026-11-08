#!/bin/bash
export LANG=en_US.UTF-8
case "$(uname -m)" in
	x86_64 | x64 | amd64 )
	cpu=amd64
	;;
	i386 | i686 )
        cpu=386
	;;
	armv8 | armv8l | arm64 | aarch64 )
        cpu=arm64
	;;
	armv7l )
        cpu=arm
	;;
        mips64le )
        cpu=mips64le
	;;
        mips64 )
        cpu=mips64
	;;
        mips )
        cpu=mipsle
	;;
        mipsle )
        cpu=mipsle
	;;
	* )
	echo "当前架构为$(uname -m)，暂不支持"
	exit
	;;
esac
if [ ! -f openwrt_cdnip_update ]; then
# 初始化包列表
packages=""
# 创建一个包名数组和一个命令名数组
package_names=("bash" "jq" "wget" "curl" "sed" "unzip" "coreutils" "coreutils-timeout" "coreutils-base64")
command_names=("bash" "jq" "wget" "curl" "sed" "unzip" "tr" "timeout" "base64")
# 遍历命令名数组
for i in ${!command_names[@]}; do
  # 如果对应的命令没有安装，那么就把对应的包名添加到包列表中
  if ! command -v ${command_names[$i]} &> /dev/null; then
    packages="$packages ${package_names[$i]}"
  fi
done
	# 判断系统进行安装
	if [ -n "$packages" ]; then
	    echo "经检测，需要安装依赖: $packages"    
	    if cat /etc/issue /proc/version /etc/os-release 2>/dev/null | grep -q -E -i "alpine"; then
	        apk update
	        apk add $packages
	    elif cat /etc/issue /proc/version /etc/os-release 2>/dev/null | grep -q -E -i "openwrt"; then
	        opkg update
	        opkg install $packages
	        opkg install coreutils-timeout
	        opkg install coreutils-base64
            elif cat /etc/issue /proc/version /etc/os-release 2>/dev/null | grep -q -E -i "ubuntu|debian"; then
	        sudo apt-get update -y
	        sudo apt-get install $packages -y
	    elif cat /etc/issue /proc/version /etc/os-release 2>/dev/null | grep -q -E -i "centos|red hat|redhat"; then
	        sudo yum install $packages -y
	    else
	        echo "未能检测出你的系统：$(uname)，请自行安装$packages这些软件。"
	        exit 1
	    fi
	fi
 touch openwrt_cdnip_update
 fi
v6=$(curl -s6m5 ip.gs -k)
ipv6test(){
if [[ -n $v6 ]]; then
echo "2：优选IPV6"
else
echo "2：无IPV6网络，请不要选择"
fi
}
cdnv4v6(){
echo
echo "1：优选IPV4"
ipv6test
read -p "请选择(回车默认为IPV4): " menu
if [ -z $menu ] || [ "$menu" == "1" ]; then
rm -rf ipv6.txt
curl -s -O https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/ip.txt
IP_ADDR=ipv4
elif [ "$menu" == "2" ]; then
if [[ -n $v6 ]]; then
rm -rf ip.txt
curl -s -O https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/ipv6.txt
IP_ADDR=ipv6
else
echo "无IPV6网络" && cdnv4v6
fi
else
echo "输入有误" && cdnv4v6
fi
}
cdnport(){
echo
echo "开启tls的端口：443、8443、2053、2083、2087、2096"
echo "关闭tls的端口：80、8080、8880、2052、2082、2086、2095"
read -p "请选择以上13个端口之一：" point
if ! [[ "$point" =~ ^(2052|2082|2086|2095|80|8880|8080|2053|2083|2087|2096|8443|443)$ ]]; then
echo "输入的端口为$opint，输入有误" && cdnport
fi
}
cdnspedurl(){
echo
echo "是否测速？（选择 1 表示测速，回车默认关闭测速）"
read -p "请选择: " menu
if [ -z $menu ]; then
CFST_URL_R=""
sed -i '29s/^CFST_SPD=.*/CFST_SPD=-dd/' /root/openwrt_cdnip/cdnip.sh
elif [ "$menu" == "1" ];then
echo "是否使用其他测速地址？（可直接输入其他测速地址 【 注意，不要带http(s):// 】 ，回车使用默认测速地址）"
read -p "请输入: " menu
if [ -z $menu ]; then
CFST_URL="е.eu.org/500.zip"
else
CFST_URL="$menu"
fi
[[ $point =~ 2053|2083|2087|2096|8443|443 ]] && htp="https://" || htp="http://"
CFST_URL_R="-url $htp$CFST_URL"
sed -i '29s/^CFST_SPD=.*/CFST_SPD=""/' /root/openwrt_cdnip/cdnip.sh
else
echo "输入有误" && cdnspedurl
fi
}
cdnym(){
echo
echo "请输入Cloudflare解析好的域名（二级域名格式）"
echo "例：1.test.eu.org空格2.test.eu.org空格3.test.eu.org…………以此类推，多域名之间有空格"
read -p "请输入域名: " cfym
if [ -z $cfym ]; then
echo "不可为空，请重新输入" && cdnym
fi
hostname="($cfym)"
}
cdnymonly(){
echo
read -p "请输入Cloudflare解析好的一级域名: " opymyj
if [ -z $opymyj ]; then
echo "不可为空，请重新输入" && cdnymonly
fi
domain=$opymyj
read -p "请输入二级域自定义的名称: " opymmc
if [ -z $opymmc ]; then
echo "不可为空，请重新输入" && cdnymonly
fi
subdomain=$opymmc
}
cdnsptime(){
echo
read -p "请输入重启代理插件后的等待时间多少秒（回车默认30秒）: " sptime
if [ -z $sptime ]; then
sed -i "35s/^sleepTime=.*/sleepTime=30/" /root/openwrt_cdnip/cdnip.sh
else
sed -i "35s/^sleepTime=.*/sleepTime=$sptime/" /root/openwrt_cdnip/cdnip.sh
fi
}
cdnyik(){
echo
read -p "请输入Cloudflare登录邮箱: " cfmail
x_email=$cfmail
echo
read -p "请输入Cloudflare域名-概述-区域ID: " cfid
zone_id=$cfid
echo
read -p "请输入Cloudflare域名-概述-获取您的API令牌-Global API Key: " cfkey
api_key=$cfkey
}
cdntg(){
echo
read -p "是否启用Telegram机器人通知(回车默认不启用，选择1启用): " menu
if [ -z $menu ]; then
tgken=""
tguserid=""
elif [ "$menu" == "1" ];then
read -p "输入Telegram机器人Token: " token
tgken=$token
read -p "输入Telegram机器人用户ID: " userid
tguserid=$userid
else
echo "输入有误" && cdntg
fi
}
cdnpush(){
echo
read -p "是否启用Pushplus微信通知(回车默认不启用，选择1启用): " menu
if [ -z $menu ]; then
token=""
elif [ "$menu" == "1" ];then
read -p "输入Pushplus的Token: " menu
token=$menu
else
echo "输入有误" && cdnpush
fi
}
cdnopcl(){
echo
echo "输入使用的代理插件【 0代表不使用任何插件 1代表Passwall 2代表Passwall2 3代表SSR-Plus 4代表Clash 5代表Openclash 6代表Bypass 7代表V2raya 8代表Hello-World 9代表Homeproxy 10代表MihomoTProxy 11代表ShellCrash 】"
read -p "请输入一个数值（0-11）: " num
if [[ $num =~ ^[0-9]$ || $num == 10 || $num == 11 ]]; then
clien=$num
else
echo "输入有误" && cdnopcl
fi
}
install(){
rm -rf /root/openwrt_cdnip/cdnip.sh
mkdir -p /root/openwrt_cdnip
cd /root/openwrt_cdnip
curl -sSL https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/cdnip.sh -o cdnip.sh
curl -sSL https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/cdnac.sh -o cdnac.sh
if [ ! -f cfst ]; then
curl -L -o cfst -# --retry 2 https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/bin/$cpu
chmod +x cfst
fi
if [ ! -f cfst ] || [ ! -f cdnip.sh ] || [ ! -f cdnac.sh ]; then
echo "下载必要文件失败，请确保你的网络通畅，建议开启代理" && exit
fi
echo
echo "1：域名解析推送模式（需要域名，推荐）"
echo "2：IP直接推送模式（无需域名）"
read -p "请选择: " ymorip
if [ "$ymorip" == "1" ]; then
echo
echo "选择优选IP分配到域名解析的方案"
echo "1：多个优选IP解析到一个域名"
echo "2：每个优选IP解析到每个域名"
read -p "请选择: " ymoryms
if [ "$ymoryms" == "1" ]; then
cdnymonly
else
cdnym
sed -i "33s/^ymoryms=.*/ymoryms=2/" /root/openwrt_cdnip/cdnip.sh
fi
echo
else
sed -i "30s/^ymorip=.*/ymorip=2/" /root/openwrt_cdnip/cdnip.sh
echo
fi
echo "使用哪种优选IP方式"
echo "1：Cloudflare CDN官方IP（强烈推荐！支持IPV4与IPV6）"
echo "2：Cloudflare CDN反代IP（仅支持ipv4）"
read -p "请选择(回车默认为官方IP): " menu
if [ -z $menu ] || [ "$menu" == "1" ]; then
cdnv4v6
else
rm -rf ipv6.txt
curl -Ls https://cf.yg-kkk.gq -o txt.zip
unzip -o txt.zip -d txt > /dev/null 2>&1
IP_ADDR=ipv4
fi
sleep 1
cdnport
sleep 1
cdnspedurl
sleep 1
echo
read -p "请输入测试线程数量【不懂就回车，默认200 最多1000】: " menu
if [ -z $menu ]; then
CFST_N=200
else
CFST_N=$menu
fi
sleep 1
echo
read -p "请输入测试并显示的IP数量【不懂就回车，默认10】: " menu
if [ -z $menu ]; then
CFST_DN=10
else
CFST_DN=$menu
fi
sleep 1
echo
read -p "请输入平均延迟上限【不懂就回车】: " menu
if [ -z $menu ]; then
CFST_TL=9999
else
CFST_TL=$menu
fi
sleep 1
echo
read -p "请输入平均延迟下限【不懂就回车】: " menu
if [ -z $menu ]; then
CFST_TLL=0
else
CFST_TLL=$menu
fi
sleep 1
echo
read -p "请输入下载速度下限【不懂就回车】: " menu
if [ -z $menu ]; then
CFST_SL=0
else
CFST_SL=$menu
fi
sleep 1
cdnopcl
sleep 1
cdnsptime
sleep 1
if [ "$ymorip" == "1" ]; then
cdnyik
sleep 1
fi
cdntg
sleep 1
cdnpush
sleep 1
sed -i "s/oppoint/$point/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opv4v6/$IP_ADDR/" /root/openwrt_cdnip/cdnip.sh
if [ "$ymorip" == "1" ]; then
if [ "$ymoryms" == "1" ]; then
hostname="(NO_name)"
sed -i "s/opymyj/$domain/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opymmc/$subdomain/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opym/$hostname/" /root/openwrt_cdnip/cdnip.sh
else
domain="NO_name"
subdomain="NO_name"
sed -i "s/opymyj/$domain/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opymmc/$subdomain/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opym/$hostname/" /root/openwrt_cdnip/cdnip.sh
fi
sed -i "s/opmail/$x_email/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opcfid/$zone_id/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opcfkey/$api_key/" /root/openwrt_cdnip/cdnip.sh
fi
sed -i "s/opnum/$CFST_N/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opsnum/$CFST_DN/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opup/$CFST_TL/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opdo/$CFST_TLL/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opsd/$CFST_SL/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/opcli/$clien/" /root/openwrt_cdnip/cdnip.sh
sed -i "s#opspd#$CFST_URL_R#" /root/openwrt_cdnip/cdnip.sh
sed -i "s/optgken/$tgken/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/optgid/$tguserid/" /root/openwrt_cdnip/cdnip.sh
sed -i "s/oppushtk/$token/" /root/openwrt_cdnip/cdnip.sh
bash cdnip.sh
}
spedlinktr(){
echo
echo "是否测速？（选择 1 表示测速，回车默认关闭测速）"
read -p "请选择: " menu
if [ -z $menu ]; then
sed -i '12s/CFST_URL_R="[^"]*"/CFST_URL_R=""/' /root/openwrt_cdnip/cdnip.sh
sed -i '29s/^CFST_SPD=.*/CFST_SPD=-dd/' /root/openwrt_cdnip/cdnip.sh
elif [ "$menu" == "1" ];then
echo "是否使用其他测速地址？（可直接输入其他测速地址 【 不要带http(s):// 】 ，回车使用默认测速地址）"
read -p "请输入: " menu
if [ -z $menu ]; then
CFST_URL="е.eu.org/500.zip"
else
CFST_URL="$menu"
fi
sed -i "12s#$oldport#$CFST_URL#" /root/openwrt_cdnip/cdnip.sh
sed -i '29s/^CFST_SPD=.*/CFST_SPD=""/' /root/openwrt_cdnip/cdnip.sh
else
echo "输入有误" && exit
fi
}
spedlinkfa(){
echo
echo "是否使用其他测速地址？（可直接输入其他测速地址 【 不要带http(s):// 】 ，回车使用默认测速地址）"
read -p "请输入: " menu
if [ -z $menu ]; then
CFST_URL="е.eu.org/500.zip"
else
CFST_URL="$menu"
fi
[[ $(sed -n '3s/.*=//p' /root/openwrt_cdnip/cdnip.sh) =~ 2053|2083|2087|2096|8443|443 ]] && htp="https://" || htp="http://"
spedlink="-url $htp$CFST_URL"
sed -i '12s#CFST_URL_R=""#CFST_URL_R="'"$spedlink"'"#' /root/openwrt_cdnip/cdnip.sh
sed -i '29s/^CFST_SPD=.*/CFST_SPD=""/' /root/openwrt_cdnip/cdnip.sh
}
changeinstall(){
if [ ! -f /root/openwrt_cdnip/cdnip.sh ]; then
echo "未安装脚本，无法变更参数配置" && exit
fi
echo
[[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && echo "1.当前为域名解析推送模式（需要域名，推荐），更换为IP直接推送模式（无需域名）" || echo "1.当前为IP直接推送模式（无需域名），更换为域名解析推送模式（需要域名，推荐），注意：请确认选项 8 与 9 已有参数后再确认执行"
[ -f /root/openwrt_cdnip/txt.zip ] && echo "2.当前为CDN反代IP模式，更换为CDN官方IP模式" || echo "2.当前为CDN官方IP模式，更换为CDN反代IP模式"
if [[ $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
echo "3.当前为多个优选IP解析到一个域名方案，更换为每个优选IP解析到每个域名方案"
elif [[ ! $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
echo "3.当前为每个优选IP解析到每个域名方案，更换为多个优选IP解析到一个域名方案"
else
echo "3.当前为IP直接推送模式，不支持域名解析方案的选择"
fi
echo "4.切换优选IPV4或者IPV6"
echo "5.更换端口"
echo "6.开启、关闭测速，更换测速网站"
echo "7.更换软路由OpenWrt代理插件"
echo "8.更改重启代理插件后的等待时间"
echo "9.更换CF解析的域名"
echo "10.更换CF邮箱、区域ID、API Key"
echo "11.关闭、开启Telegram机器人通知，更换Token、用户ID"
echo "12.切换Telegram api接口的域名地址"
echo "13.关闭、开启Pushplus微信通知，更换Token"
echo "============================================"
echo "以上选项更改完毕之后，请输入 Y/y ，表示确认执行"
echo "============================================"
echo "14.退出"
echo
read -p "请输入: " menu
if [[ "$menu" == [Yy] ]]; then
bash cdnip.sh
elif [ "$menu" == "1" ]; then
if [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
sed -i "30s/^ymorip=.*/ymorip=2/" /root/openwrt_cdnip/cdnip.sh
echo "当前为IP直接推送模式（无需域名）" && sleep 2
else
sed -i "30s/^ymorip=.*/ymorip=1/" /root/openwrt_cdnip/cdnip.sh
echo "当前为域名解析推送模式（需要域名，推荐），注意，请确认选项 7 与 8 已有参数后再确认执行" && sleep 2
fi
changeinstall
elif [ "$menu" == "2" ]; then
oldport=$(sed -n '4s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
if [ -f txt.zip ]; then
rm -rf txt.zip
cdnv4v6
else
rm -rf ipv6.txt
curl -Ls https://cf.yg-kkk.gq -o txt.zip
unzip -o txt.zip -d txt > /dev/null 2>&1
IP_ADDR=ipv4
fi
sed -i "4s/$oldport/$IP_ADDR/" /root/openwrt_cdnip/cdnip.sh
changeinstall
elif [ "$menu" == "3" ]; then
echo
if [[ ! $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
sed -i "33s/^ymoryms=.*/ymoryms=1/" /root/openwrt_cdnip/cdnip.sh
echo "已切换为多个优选IP解析到一个域名方案，注意，请确认 域名 与 CF相关信息 已有参数后再确认执行" && sleep 2
elif [[ $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
sed -i "33s/^ymoryms=.*/ymoryms=2/" /root/openwrt_cdnip/cdnip.sh
echo "已切换为每个优选IP解析到每个域名方案，注意，请确认 域名 与 CF相关信息 已有参数后再确认执行" && sleep 2
else
echo "当前为无域名解析方案，请先在选项1，选择域名解析推送模式" && sleep 2
fi
changeinstall
elif [ "$menu" == "4" ]; then
echo
oldport=$(sed -n '4s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "当前为优选$oldport"
echo
if [ -f txt.zip ]; then
echo "当前为CDN反代IP模式，仅支持优选ipv4" && sleep 2 && changeinstall
else
cdnv4v6
fi
sed -i "4s/$oldport/$IP_ADDR/" /root/openwrt_cdnip/cdnip.sh
changeinstall
elif [ "$menu" == "5" ]; then
echo
oldport=$(sed -n '3s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "当前使用的端口：$oldport"
cdnport
sed -i "3s/$oldport/$point/" /root/openwrt_cdnip/cdnip.sh
[[ $point =~ 2053|2083|2087|2096|8443|443 ]] && htp="https" || htp="http"
sed -i "12s/http\|https/$htp/" /root/openwrt_cdnip/cdnip.sh
changeinstall
elif [ "$menu" == "6" ]; then
echo
oldport=$(sed -n '12s/.*:\/\/\([^ ]*\).*/\1/p' /root/openwrt_cdnip/cdnip.sh | tr -d '"')
if [[ $oldport =~ 'bestip' ]] && [[ ! $(sed -n '29p' /root/openwrt_cdnip/cdnip.sh) == *"-dd"* ]]; then
echo "测速已开启，当前为默认测速网站"
spedlinktr
elif [[ ! $oldport =~ 'bestip' ]] && [[ ! $(sed -n '29p' /root/openwrt_cdnip/cdnip.sh) == *"-dd"* ]]; then
echo "测速已开启，当前使用的测速网站：$oldport"
spedlinktr
else
echo "当前已关闭测速"
spedlinkfa
fi
changeinstall
elif [ "$menu" == "7" ]; then
echo
oldport=$(sed -n '10s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
case $oldport in
  "11") oldport1=ShellCrash;;
  "10") oldport1=MihomoTProxy;;
  "9") oldport1=Homeproxy;;
  "8") oldport1=Hello-World;;
  "7") oldport1=V2raya;;
  "6") oldport1=Bypass;;
  "5") oldport1=Openclash;;
  "4") oldport1=Clash;;
  "3") oldport1=SSR-Plus;;
  "2") oldport1=Passwall2;;
  "1") oldport1=Passwall;;
  "0") oldport1=不使用任何插件;;
esac
echo "当前使用的代理插件：$oldport1"
cdnopcl
sed -i "10s/$oldport/$clien/" /root/openwrt_cdnip/cdnip.sh
changeinstall
elif [ "$menu" == "8" ]; then
echo
oldport=$(sed -n '35s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "当前重启代理插件后的等待时间：$oldport秒"
cdnsptime
changeinstall
elif [ "$menu" == "9" ]; then
if [[ $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
echo "当前为多个优选IP解析到一个域名方案"
echo
oldport=$(sed -n '31s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
oldport1=$(sed -n '32s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "当前使用的一级域名：$oldport"
echo "当前使用的二级域自定义名称：$oldport1"
cdnymonly
sed -i "31s/$oldport/$domain/" /root/openwrt_cdnip/cdnip.sh
sed -i "32s/^subdomain=.*/subdomain=$subdomain/" /root/openwrt_cdnip/cdnip.sh
elif [[ ! $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
echo "当前为每个优选IP解析到每个域名方案"
echo
oldport=$(sed -n '6s/.*=//p' /root/openwrt_cdnip/cdnip.sh | tr -d '()')
echo "当前使用的域名：$oldport"
cdnym
sed -i "6s/($oldport)/$hostname/" /root/openwrt_cdnip/cdnip.sh
else
echo "当前为无域名解析方案，如要切换域名解析推送模式，请在更改配置菜单-选项1中进行切换" && sleep 2
fi
changeinstall
elif [ "$menu" == "10" ]; then
echo
oldport1=$(sed -n '5s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
oldport2=$(sed -n '7s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
oldport3=$(sed -n '8s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "当前使用的邮箱：$oldport1"
echo "当前使用的区域ID：$oldport2"
echo "当前使用的API Key：$oldport3"
cdnyik
sed -i "5s/$oldport1/$x_email/" /root/openwrt_cdnip/cdnip.sh
sed -i "7s/$oldport2/$zone_id/" /root/openwrt_cdnip/cdnip.sh
sed -i "8s/$oldport3/$api_key/" /root/openwrt_cdnip/cdnip.sh
changeinstall
elif [ "$menu" == "11" ]; then
echo
oldport1=$(sed -n '26s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
oldport2=$(sed -n '27s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
if [[ -z $oldport1 || -z $oldport2 ]]; then
echo "未设置telegram机器人通知"
else
echo "当前Telegram机器人Token：$oldport1"
echo "当前Telegram机器人用户ID：$oldport2"
fi
cdntg
sed -i "26s/^telegramBotToken=.*/telegramBotToken=$tgken/" /root/openwrt_cdnip/cdnip.sh
sed -i "27s/^telegramBotUserId=.*/telegramBotUserId=$tguserid/" /root/openwrt_cdnip/cdnip.sh
changeinstall
elif [ "$menu" == "12" ]; then
echo
oldport1=$(sed -n '36s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "当前使用的TG api接口的域名地址：$oldport1"
echo
read -p "请输入要更改的TG api接口的域名地址【 回车默认使用TG官方api，输入时不要带https:// 】: " menu
if [ -z $menu ]; then
tgapi=api.telegram.org
else
tgapi=$menu
fi
sed -i "36s#^tgapi=.*#tgapi=$tgapi#" /root/openwrt_cdnip/cdnip.sh
changeinstall
elif [ "$menu" == "13" ]; then
echo
oldport1=$(sed -n '34s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
if [[ -z $oldport1 ]]; then
echo "未设置Pushplus微信通知"
else
echo "当前Pushplus的Token：$oldport1"
fi
cdnpush
sed -i "34s/^token=.*/token=$token/" /root/openwrt_cdnip/cdnip.sh
changeinstall
else
exit
fi
}
#sed -n '3s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '4s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '5s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '6s/.*=//p' /root/openwrt_cdnip/cdnip.sh | tr -d '()'
#sed -n '7s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '8s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '10s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '12s/.*:\/\/\([^ ]*\).*/\1/p' /root/openwrt_cdnip/cdnip.sh | tr -d '"'
#sed -n '14s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '18s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '20s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '22s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '24s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '26s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -n '27s/.*=//p' /root/openwrt_cdnip/cdnip.sh
#sed -i '29s/^CFST_SPD=.*/CFST_SPD=""/' /root/openwrt_cdnip/cdnip.sh
#sed -i '29s/^CFST_SPD=.*/CFST_SPD=-dd/' /root/openwrt_cdnip/cdnip.sh
showcdn(){
if [ -f /root/openwrt_cdnip/cdnip.sh ]; then
echo
echo "自动优选IP脚本正在运行中，详细配置如下："
echo "====================================================="
[[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && echo "1、当前为域名解析推送模式（需要域名，推荐）" || echo "1、当前为IP直接推送模式（无需域名）"
echo
if [[ $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
echo "2、当前为多个优选IP解析到一个域名方案"
elif [[ ! $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
echo "2、当前为每个优选IP解析到每个域名方案"
else
echo "2、当前为无域名解析方案"
fi
echo
[ -f /root/openwrt_cdnip/txt.zip ] && echo "3、当前为CDN反代IP模式" || echo "3、当前为CDN官方IP模式"
echo
echo "4、当前为优选$(sed -n '4s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
echo "5、使用的端口：$(sed -n '3s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
old12=$(sed -n '12s/.*:\/\/\([^ ]*\).*/\1/p' /root/openwrt_cdnip/cdnip.sh | tr -d '"')
if [[ $old12 =~ 'bestip' ]] && [[ ! $(sed -n '29p' /root/openwrt_cdnip/cdnip.sh) == *"-dd"* ]]; then
echo "6、测速已开启，当前为默认测速网站"
elif [[ ! $old12 =~ 'bestip' ]] && [[ ! $(sed -n '29p' /root/openwrt_cdnip/cdnip.sh) == *"-dd"* ]]; then
echo "6、测速已开启，当前使用的测速网站：$old12"
else
echo "6、当前已关闭测速"
fi
echo
oldport=$(sed -n '10s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
case $oldport in
  "10") oldport=MihomoTProxy;;
  "9") oldport=Homeproxy;;
  "8") oldport=Hello-World;;
  "7") oldport=V2raya;;
  "6") oldport=Bypass;;
  "5") oldport=Openclash;;
  "4") oldport=Clash;;
  "3") oldport=SSR-Plus;;
  "2") oldport=Passwall2;;
  "1") oldport=Passwall;;
  "0") oldport=不使用任何插件;;
esac
echo "7、当前使用的代理插件：$oldport"
echo
oldport35=$(sed -n '35s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "8、当前重启代理插件后的等待时间：$oldport35秒"
echo
if [[ $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
old31=$(sed -n '31s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
old32=$(sed -n '32s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "9、当前使用的二级域自定义名称：$old32  一级域名：$old31 "
elif [[ ! $(sed -n '33p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]] && [[ $(sed -n '30p' /root/openwrt_cdnip/cdnip.sh | grep "1") ]]; then
old6=$(sed -n '6s/.*=//p' /root/openwrt_cdnip/cdnip.sh | tr -d '()')
echo "9、当前使用的域名：$old6"
else
echo "9、当前无域名显示"
fi
echo
echo "10、使用的邮箱：$(sed -n '5s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
echo "11、使用的区域ID：$(sed -n '7s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
echo "12、使用的API Key：$(sed -n '8s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
old26=$(sed -n '26s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
old27=$(sed -n '27s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
if [[ -z $old26 && -z $old27 ]]; then
echo "13、未设置telegram机器人通知"
else
echo "13、Telegram机器人Token：$old26"
echo
echo "13、Telegram机器人用户ID：$old27"
echo
old36=$(sed -n '36s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
echo "13、当前使用的TG api：$old36"
fi
echo
old34=$(sed -n '34s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
if [[ -z $old34 ]]; then
echo "14、未设置Pushplus微信通知"
else
echo "14、Pushplus的Token：$old34"
fi
echo
echo "测速线程数量：$(sed -n '14s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
echo "测速显示数量：$(sed -n '18s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
echo "平均延迟上限：$(sed -n '20s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
echo "平均延迟下限：$(sed -n '22s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
echo "下载速度下限：$(sed -n '24s/.*=//p' /root/openwrt_cdnip/cdnip.sh)"
echo
echo "切记：在软路由-计划任务选项中，加入优选IP自动执行时间的cron表达式"
echo "比如每天早上三点执行：0 3 * * * cd /root/openwrt_cdnip/ && bash cdnip.sh"
echo "====================================================="
echo
fi
}
runcdnopw(){
if [ -f /root/openwrt_cdnip/cdnip.sh ]; then
cd /root/openwrt_cdnip/ && bash cdnip.sh
else
echo "未安装此脚本，无法执行"
fi
}
rmrf(){
y
echo "卸载完成"
}
ipv4ipv6(){
if [[ -n $v6 ]]; then
echo "当前网络：支持IPV4与IPV6"
else
echo "当前网络：仅支持IPV4，无IPV6"
fi
}
deallym(){
echo
read -p "请输入Cloudflare解析好的一级域名: " domain
echo
read -p "请输入二级域指定的名称: " subdomain
cdnyik
url="https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records"
params="name=${subdomain}.${domain}&type="
response=$(curl -sm10 -X GET "$url?$params" -H "X-Auth-Email: $x_email" -H "X-Auth-Key: $api_key")
if [[ $(echo "$response" | jq -r '.success') == "true" ]]; then
    records=$(echo "$response" | jq -r '.result')
    if [[ $(echo "$records" | jq 'length') -gt 0 ]]; then
        for record in $(echo "$records" | jq -c '.[]'); do
            record_id=$(echo "$record" | jq -r '.id')
            delete_url="$url/$record_id"
            delete_response=$(curl -sm10 -X DELETE "$delete_url" -H "X-Auth-Email: $x_email" -H "X-Auth-Key: $api_key")
            if [[ $(echo "$delete_response" | jq -r '.success') == "true" ]]; then
                echo "成功删除 DNS 记录：$(echo "$record" | jq -r '.name')"
            else
                echo "删除 DNS 记录失败"
            fi
        done
    else
        echo "没有找到指定的 DNS 记录"
    fi
else
    echo "获取 DNS 记录失败"
fi
}
echo "--------------------------------------------------------------"
echo "项目地址        ：github.com/jane2003/openwrt_cdnip"
echo "脚本原作者      ：yonggekkk (github.com/yonggekkk)"
echo "二进制上游      ：gitlab.com/rwkgyg/CFwarp"
echo "--------------------------------------------------------------"
echo "OpenWrt软路由-优选IP解析到CF域名脚本    V2024.4.1"
ipv4ipv6
echo "--------------------------------------------------------------"
showcdn
echo "1.安装/重置脚本"
echo "2.更改各项参数配置"
echo "3.运行一次已配置完成的脚本"
echo "4.删除CF域名指定名称解析记录"
echo "5.卸载"
echo "0.退出"
read -p "请选择: " menu
if [ "$menu" == "1" ];then
install
elif [ "$menu" == "2" ];then
cd /root/openwrt_cdnip
changeinstall
elif [ "$menu" == "3" ];then
runcdnopw
elif [ "$menu" == "4" ];then
deallym
elif [ "$menu" == "5" ];then
rmrf
else 
exit
fi
