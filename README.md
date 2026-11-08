# openwrt_cdnip

在 OpenWrt 软路由上优选 Cloudflare IP，并把结果自动解析到 CF 域名或直接推送到代理节点。

本项目是 [yonggekkk/openwrt_win64-ddns-cdnip](https://github.com/yonggekkk/openwrt_win64-ddns-cdnip) 的 GitHub 自建镜像版，脚本与上游二进制全部照搬原作者，功能未改，只把下载源从 GitLab 换成 GitHub、安装目录和签名改成独立的一套。

## 安装

SSH 进路由器，在 `/root` 下执行：

```bash
curl -ksSL https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/cdnopw.sh -o cdnopw.sh && bash cdnopw.sh
```

raw 域名不通时用 jsDelivr：

```bash
curl -ksSL https://cdn.jsdelivr.net/gh/jane2003/openwrt_cdnip@main/cdnopw.sh -o cdnopw.sh && bash cdnopw.sh
```

装完后再次进入菜单：

```bash
bash cdnopw.sh
```

## 菜单

```
1.安装/重置脚本      首次全量配置，会依次问：域名解析还是 IP 直推、优选 IPV4/IPV6、端口、是否测速、线程数、延迟上下限、速度下限、代理插件、CF 邮箱/区域ID/API Key、TG 或 Pushplus 推送
2.更改各项参数配置    单项改参数，改完输入 Y 生效
3.运行一次已配置的脚本
4.删除CF域名指定名称解析记录
5.卸载
```

配置与运行文件都在 `/root/openwrt_cdnip/`：

| 文件 | 作用 |
| --- | --- |
| `cdnip.sh` | 主脚本，跑测速 + 写 DNS 记录 |
| `cdnac.sh` | 反代 IP 地区识别，反代模式才用 |
| `cfst` | CloudflareSpeedTest 改版，按 CPU 架构自动选 |
| `ip.txt` / `ipv6.txt` | 优选用的 IP 段 |
| `result.csv` | 测速结果 |

## 定时执行

系统 - 计划任务里加一行，比如每天 3 点：

```
0 3 * * * cd /root/openwrt_cdnip/ && bash cdnip.sh
```

## 和原作者版本的差异

只改了下面这些，功能逻辑、提示文案、参数名都没动：

1. 所有下载源由 `gitlab.com/rwkgyg/...` 换成本仓库的 `raw.githubusercontent.com/jane2003/openwrt_cdnip/main/...`。
2. 安装目录由 `/root/cfipopw` 改为 `/root/openwrt_cdnip`，两套脚本可以并存，不会互相覆盖。
3. 首次运行标记 `ygop_update` 改为 `openwrt_cdnip_update`。
4. 菜单抬头改成项目地址与原作者署名。
5. `install()` 里原本用相对路径 `mkdir -p cfipopw; cd cfipopw`，改为绝对路径，避免不在 `/root` 下执行时路径错乱。

## 上游说明

- 脚本作者：yonggekkk（[GitHub](https://github.com/yonggekkk) / [博客](https://ygkkk.blogspot.com)），原脚本托管在 `gitlab.com/rwkgyg/cdnopw`。
- `cfst` 二进制取自 `gitlab.com/rwkgyg/CFwarp` 的 `point/cpu3`，是 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 与 [badafans](https://github.com/badafans/Cloudflare-IP-SpeedTest) 版本的改版。
- `ip.txt` / `ipv6.txt` 为 Cloudflare 官方 IP 段，同样取自上述上游。

本仓库不做功能开发，只跟随上游更新。原作者项目未附开源许可证，这里的镜像保留完整署名，仅供个人安装使用，请勿用于商业分发。

## 已知限制

- 原作者 2025.7.10 起已停止维护反代 IP 上游（`cf.yg-kkk.gq`），反代 IP 模式实际不可用，只能用官方 IP 模式。
- 支持架构：amd64、arm64、arm(v7)、mips、mipsle、mips64、mips64le。x86 32 位无对应二进制。
- 只用来做 HTTP/HTTPS 代理端口的 IP 优选与 DNS 解析，本身不是代理程序。
