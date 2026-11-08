#!/bin/bash
export LANG=en_US.UTF-8
if [[ -f /root/openwrt_cdnip/txt.zip && -f /root/openwrt_cdnip/informlog ]]; then
echo
echo "请稍等，对优选反代IP进行地区识别，最多显示前10个IP"
rm -rf cdnIP.csv b.csv a.csv
awk -F ',' 'NR>1 && NR<=11 {print $1}' result.csv > a.csv
while IFS= read -r ip_address; do
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
response=$(curl -sm5 --user-agent "${UA_Browser}" "https://api.ip.sb/geoip/$ip_address" -k | awk -F "country_code" '{print $2}' | awk -F'":"|","|"' '{print $2}')
if [ $? -eq 0 ]; then
echo "IP地址 $ip_address 的地区是: $response" | tee -a b.csv
else
echo "无法获取IP地址 $ip_address 的地区信息" | tee -a b.csv
fi
sleep 1
done < "a.csv"
echo -e "\n优选反代IP--国家地区识别" >> cdnIP.csv
cat b.csv >> cdnIP.csv
#grep 'SG' b.csv | head -n 10 >> cdnIP.csv
#grep 'HK' b.csv | head -n 10 >> cdnIP.csv
#grep 'JP' b.csv | head -n 10 >> cdnIP.csv
#grep 'KR' b.csv | head -n 10 >> cdnIP.csv
#grep 'TW' b.csv | head -n 10 >> cdnIP.csv
#grep 'US' b.csv | head -n 10 >> cdnIP.csv
#grep 'GB' b.csv | head -n 10 >> cdnIP.csv
#grep 'DE' b.csv | head -n 10 >> cdnIP.csv
#grep 'NL' b.csv | head -n 10 >> cdnIP.csv
#grep 'FR' b.csv | head -n 10 >> cdnIP.csv
echo
cat cdnIP.csv >> informlog
fi
if [[ -f /root/openwrt_cdnip/txt.zip && ! -f /root/openwrt_cdnip/informlog ]]; then
echo "下载更新反代IP库txt.zip文件……"
wget -q https://zip.baipiao.eu.org -O txt.zip
if [ $? -eq 0 ]; then
echo "下载成功"
else
curl -L -# --retry 2 https://cf.yg-kkk.gq -o txt.zip
if [ $? -eq 0 ]; then
echo "下载成功"
else
echo "下载失败，继续使用之前的反代IP库"
fi
fi
rm -rf txt
unzip -o txt.zip -d txt > /dev/null 2>&1
if [[ ! -e "txt" ]]; then
echo "反代IP库txt.zip文件下载失败" && exit
fi
point=$(sed -n '3s/.*=//p' /root/openwrt_cdnip/cdnip.sh)
if [ "$point" == "443" ]; then
find txt -type f -name "*443*" ! -name "*8443*" -exec cat {} \; > ip.txt
elif [ "$point" == "80" ]; then
find txt -type f -name "*80*" ! -name "*8880*" ! -name "*8080*" -exec cat {} \; > ip.txt
else
find txt -type f -name "*${point}*"  -exec cat {} \; > ip.txt
fi
grep -E '^8|^47|^43|^130|^132|^152|^193|^140|^138|^150|^143|^141|^155|^168|^124|^170|^119' ip.txt > pass.txt && mv pass.txt ip.txt
fi
