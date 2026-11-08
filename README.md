# openwrt_cdnip

在 OpenWrt 软路由上优选 Cloudflare IP，并把结果自动解析到 CF 域名或直接推送到代理节点。

本项目是 [yonggekkk/openwrt_win64-ddns-cdnip](https://github.com/yonggekkk/openwrt_win64-ddns-cdnip) 的自建镜像版。原作者脚本托管在 GitLab，且是多层 base64 混淆，国内经常连不上、也改不了；这里换成解密后的明文，下载源全部走 GitHub，并加了国内可用的镜像回退。

## 安装

SSH 进路由器，在 `/root` 下执行：

```bash
curl -ksSL https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/cdnopw.sh -o cdnopw.sh && bash cdnopw.sh
```

raw 解析失败或被墙时换镜像（任选一条）：

```bash
curl -ksSL https://ghproxy.net/https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/cdnopw.sh -o cdnopw.sh && bash cdnopw.sh
```

```bash
curl -ksSL https://ghfast.top/https://raw.githubusercontent.com/jane2003/openwrt_cdnip/main/cdnopw.sh -o cdnopw.sh && bash cdnopw.sh
```

```bash
curl -ksSL https://cdn.jsdelivr.net/gh/jane2003/openwrt_cdnip@main/cdnopw.sh -o cdnopw.sh && bash cdnopw.sh
```

装完再次进入菜单：

```bash
bash cdnopw.sh
```

脚本内部下载 `cdnip.sh`、`cdnac.sh`、`cfst`、`ip.txt` 时也会按 raw → ghproxy → ghfast → jsDelivr 的顺序重试，任意一条通就能装完。

## 首次安装的交互项

选 `1.安装/重置脚本` 后按下面顺序依次提问。写“回车”的可以直接回车用默认值，其余必须输入。

### 一、模式

| 顺序 | 提示 | 可选值 | 默认 | 需要提前准备 |
| --- | --- | --- | --- | --- |
| 1 | 域名解析推送模式 / IP直接推送模式 | `1` 域名解析推送：把优选出的 IP 写成 CF 的 A/AAAA 记录；`2` IP 直接推送：不碰域名，只输出 IP 列表，给代理插件或别的脚本取用 | 无，必须选 | 选 `1` 要准备：CF 登录邮箱、区域 ID、Global API Key、已在 CF 建好的域名 |
| 2 | 优选 IP 分配方案（仅模式 `1` 才会问） | `1` 多个优选 IP 解析到一个域名（同一子域写多条 A 记录）；`2` 每个优选 IP 解析到每个域名（第 N 个 IP 写第 N 个域名） | 无，必须选 | 方案 `1` 要一个一级域名加一个自定义二级名；方案 `2` 要一组已解析好的完整域名 |
| 3 | 使用哪种优选 IP 方式 | `1` CF 官方 IP（支持 v4/v6）；`2` CF 反代 IP（只有 v4） | 回车 = `1` | 反代上游 `cf.yg-kkk.gq` 已失效，实际只能用 `1` |

### 二、优选参数

| 顺序 | 提示 | 说明 | 默认 | 备注 |
| --- | --- | --- | --- | --- |
| 4 | 优选 IPV4 / IPV6 | 决定用 `ip.txt` 还是 `ipv6.txt` | 回车 = IPV4 | 路由器没有 IPv6 时菜单会写“无IPV6网络，请不要选择” |
| 5 | 选择端口 | TLS：443、8443、2053、2083、2087、2096；明文：80、8080、8880、2052、2082、2086、2095 | 无，必须输 | 要和你代理节点用的端口一致 |
| 6 | 是否测速 | 回车 = 只测延迟（`CFST_SPD=-dd`）；输 `1` = 带下载测速，可再指定测速地址（不带 `http(s)://`，默认 `е.eu.org/500.zip`） | 回车 = 关闭 | 关闭更快，延迟好看通常够用 |
| 7 | 测试线程数量 | 1–1000 | 回车 = 200 | 弱机器（如 MT7621）建议 50 以内 |
| 8 | 测试并显示的 IP 数量 | 结果表里留几条 | 回车 = 10 | 方案 `2` 时会被域名数量顶上去 |
| 9 | 平均延迟上限 | 毫秒 | 回车 = 9999 | 只想留低延迟的填 300 之类 |
| 10 | 平均延迟下限 | 毫秒 | 回车 = 0 | 一般不用改 |
| 11 | 下载速度下限 | MB/s | 回车 = 0 | 没开测速时无效 |
| 12 | 代理插件 | `0` 不用、`1` Passwall、`2` Passwall2、`3` SSR-Plus、`4` Clash、`5` OpenClash、`6` Bypass、`7` V2raya、`8` Hello-World、`9` Homeproxy、`10` MihomoTProxy、`11` ShellCrash | 无，必须输 | 选了会 stop → 测速 → restart；选 `0` 完全不碰现有代理 |

### 三、域名与推送

| 顺序 | 提示 | 说明 | 需要提前准备 |
| --- | --- | --- | --- |
| 13 | 重启代理插件后的等待时间 | 秒，回车 = 30 | 无 |
| 14 | CF 登录邮箱 / 区域 ID / Global API Key（仅模式 `1`） | 三项都要，填错会重试 5 次后退出 | CF 后台 → 域名 → 概述，右下角取区域 ID；获取您的 API 令牌 → Global API Key |
| 15 | 是否启用 Telegram 机器人通知 | 输 `1` 启用，回车不启用 | 启用要 Bot Token 和你的用户 ID |
| 16 | 是否启用 Pushplus 微信通知 | 输 `1` 启用，回车不启用 | 启用要 Pushplus Token |

域名输入格式：

- 方案 `1`（多个 IP 到一个域名）：先填一级域名如 `example.com`，再填二级名如 `cdn`，最终写的是 `cdn.example.com` 的多条 A 记录。
- 方案 `2`（每个 IP 到每个域名）：一次粘贴完整域名，空格分隔，例如 `1.test.eu.org 2.test.eu.org 3.test.eu.org`。

## 菜单 2：改参数

装完选 `2.更改各项参数配置`，可以单项改，改完输入 `Y` 才生效：

| 编号 | 作用 |
| --- | --- |
| 1 | 切换域名解析推送 / IP 直接推送 |
| 2 | 切换官方 IP / 反代 IP |
| 3 | 切换解析方案（多 IP 到一个域名 ↔ 每 IP 一个域名） |
| 4 | 切换优选 IPV4 / IPV6 |
| 5 | 换端口 |
| 6 | 开关测速、换测速网站 |
| 7 | 换代理插件 |
| 8 | 改重启插件后的等待时间 |
| 9 | 换 CF 解析的域名 |
| 10 | 换 CF 邮箱、区域 ID、API Key |
| 11 | 开关 TG 通知、换 Token 和用户 ID |
| 12 | 切换 TG API 接口域名（`api.telegram.org` 不通时换成反代域名） |
| 13 | 开关 Pushplus 通知、换 Token |

## 文件位置

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

1. 脚本由多层 base64 混淆改为解密后的明文，可以直接读、直接改。
2. 所有下载源由 `gitlab.com/rwkgyg/...` 换成本仓库：`cdnip.sh`、`cdnac.sh`、`cfst` 各架构二进制（`bin/<arch>`）、`ip.txt`、`ipv6.txt` 全部放在仓库里。
3. 下载加了镜像回退：raw → ghproxy.net → ghfast.top → jsDelivr，前一条不通自动换下一条。
4. 安装目录由 `/root/cfipopw` 改为 `/root/openwrt_cdnip`，两套脚本可以并存，不会互相覆盖。
5. 首次运行标记 `ygop_update` 改为 `openwrt_cdnip_update`。
6. 菜单抬头改成项目地址与原作者署名。
7. `install()` 里原本用相对路径 `mkdir -p cfipopw; cd cfipopw`，改为绝对路径，避免不在 `/root` 下执行时路径错乱。
8. 依赖检测里去掉了 `base64` / `coreutils-base64`。原作者脚本是多层 base64 混淆的，运行必须依赖 base64；这版是解密后的明文，用不到，少装一个包。其余依赖（bash、jq、wget、curl、sed、unzip、tr、timeout）不变。

以上改动已在 aarch64 OpenWrt 上完整跑通：菜单显示、下载全部文件、参数写入、cfst 测速、生成 `result.csv`、TG/Pushplus 提示均正常。

## 上游说明

- 脚本作者：yonggekkk（[GitHub](https://github.com/yonggekkk) / [博客](https://ygkkk.blogspot.com)），原脚本托管在 `gitlab.com/rwkgyg/cdnopw`。
- `cfst` 二进制取自 `gitlab.com/rwkgyg/CFwarp` 的 `point/cpu3`，是 [XIU2/CloudflareSpeedTest](https://github.com/XIU2/CloudflareSpeedTest) 与 [badafans](https://github.com/badafans/Cloudflare-IP-SpeedTest) 版本的改版。
- `ip.txt` / `ipv6.txt` 为 Cloudflare 官方 IP 段，同样取自上述上游。

本仓库不做功能开发，只跟随上游更新。原作者项目未附开源许可证，这里的镜像保留完整署名，仅供个人安装使用，请勿用于商业分发。

## 已知限制

- 原作者 2025.7.10 起已停止维护反代 IP 上游（`cf.yg-kkk.gq`），反代 IP 模式实际不可用，只能用官方 IP 模式。
- 支持架构：amd64、arm64、arm(v7)、mips、mipsle、mips64、mips64le。x86 32 位无对应二进制。
- 只用来做 HTTP/HTTPS 代理端口的 IP 优选与 DNS 解析，本身不是代理程序。
- 推送 GitHub 后 `raw` 有几分钟 CDN 缓存，刚改完脚本时路由器可能还拉到旧文件；走 jsDelivr 的话可以用 `https://purge.jsdelivr.net/gh/jane2003/openwrt_cdnip@main/cdnopw.sh` 手动刷缓存。
