# 无界 14X 暴风雪（WUJIE14XA）NixOS 配置

本目录是这台机器的 NixOS 主机配置，以及装机、排障时会用到的资料汇总。

本文里的信息分三类，请注意区分：

- **实测**：直接在机器上跑命令读出来的结果
- **配置**：本目录 [default.nix](./default.nix) / [hardware.nix](./hardware.nix) 里实际生效的内容
- **资料**：来自社区文档、上游 issue 或他人经验，**未在本机验证**

---

## 1. 机型识别

```
DMI 厂商     MECHREVO
产品名       WUJIE14XA
主板         WUJIE14-GX4HRXL
BIOS         N.1.14MRO50 (2025-11-13)
CPU          AMD Ryzen 7 8845HS (Phoenix / Hawk Point), 8C16T, microcode 0xa705205
内存         2 × 16 GB DDR5-5600 双通道，Micron/Crucial CT16G56C46S5.C8D
             （系统可见 29 GiB，其余留给核显）
磁盘         Micron 2550 NVMe SSD 1 TB (CT1000P3PSSD8)
```

`WUJIE14XA` 是**同方 GX4HRXL 公模**，与 TUXEDO InfinityBook Pro 14 Gen9 AMD、Slimbook EVO 14 同模具。因此 TUXEDO 的驱动和官方 FAQ 基本可以照搬。

需要注意：无界 14X 系列有多个 SKU（14XA / 14XA 暴风雪 / Intel Core Ultra 7 155H 版 / 14X Pro / 斗战版），**硬件不完全相同**，网上资料要看清是哪一台。本机是 8845HS 的 14XA 暴风雪。

## 2. 硬件清单与兼容性（实测）

| 部件 | 实测标识 | 状态 | 备注 |
| --- | --- | --- | --- |
| 内存 | Micron `CT16G56C46S5.C8D` × 2 | 正常 | DDR5-5600 双通道（P0 CHANNEL A/B），实际运行 5600 MT/s |
| 无线网卡 | MediaTek MT7922 `[14c3:7922]` | 正常 | **注意：不是常见的 Intel AX200**，驱动 `mt7921e` |
| 蓝牙 | `13d3:3585` IMC Wireless_Device | 正常 | MT7922 的蓝牙部分 |
| 有线网卡 | Motorcomm YT6801 `[1f0a:6801]` | Linux 7.0+ 正常 | 6.18 内核下无驱动，见第 4 节 |
| 核显 | Radeon 780M `[1002:1900]` | 正常 | 需要 PSR 修复，见第 3 节 |
| 声卡 | `[1002:1640]` + `[1022:15e3]` | 正常 | 不需要 SOF 之类 |
| USB4 | `[1022:1669]` NHI | 存在 | C 口一线通接显示器不可靠，优先 HDMI |
| TPM | `/dev/tpm0` | 存在 | — |
| 指纹 | — | **不存在** | 电源键只有 IR 摄像头 `[04f2:b7dd]` |
| 传感器 | k10temp / amdgpu / nvme / BAT0 / spd5118 ×2 / mt7921 | 齐全 | — |
| 电池 | BAT0 + AC0 | 正常 | — |
| 睡眠 | `/sys/power/mem_sleep` = `[s2idle]` | 只有 s2idle | 该平台无 S3，BIOS 也没有开关 |

[hardware.nix](./hardware.nix) 文件头也记录了同一份清单，方便对照。

## 3. 内核参数：为什么是这两个

`hardware.nix` 里配置的：

```nix
kernelParams = [
  "acpi.ec_no_wakeup=1"
  "amdgpu.dcdebugmask=0x10"
];
```

### `acpi.ec_no_wakeup=1` — 让合盖能真的睡下去

这台机器的嵌入式控制器（EC，ACPI 里是 `PNP0C09` / `INOU0000`）会发出虚假唤醒信号，不加这个参数时**合盖瞬间就会自己醒**，是 BIOS/ACPI 层面的问题，跟发行版无关。

- ArchWiki 机型页的 "Wake up immediately from sleeping" 一节给出的就是这条参数
- TUXEDO 官方 FAQ（同模具）同样建议这条
- 社区修复仓库 sund3RRR/mechrevo14X-linux 列为 fix #2

### `amdgpu.dcdebugmask=0x10` — 解决屏幕花屏/闪烁

`0x10` 这个位禁用 Panel Self Refresh（PSR）。在 **2880×1800 eDP 屏 + Phoenix/Hawk Point 核显**的组合下，amdgpu 的 PSR 有 bug，会导致闪烁、花屏、Wayland 下卡顿。上游记录见 freedesktop.org/drm/amd issue #3388。

- 该参数在 14X 修复仓库里是 fix #1，TUXEDO 支持人员也建议过
- 有用户在此基础上再叠加 `0x2`（合计 `amdgpu.dcdebugmask=0x12`）解决闪烁，本机暂未需要

### 唤醒后键盘/触摸板失灵（暂未启用）

如果唤醒后键盘或触摸板没反应，再加 `i8042.nomux`；仍不行则补上 `i8042.nopnp` 和 `i8042.noloop`：

```nix
# "i8042.nomux" "i8042.nopnp" "i8042.noloop"
```

14XA 的修复仓库只推荐 `i8042.nomux`，而 14X 斗战版（H255）和 15X Pro 的用户报告需要三件套才有效——**这条要在本机实测确认**，所以默认注释掉。

### 不要做的事

- **不要**加 `mem_sleep_default=deep`：这台机器没有 S3，只有 s2idle
- 不需要 SOF 固件相关参数（那是 Intel 平台的）
- 不需要为 Secure Boot 配任何东西，安装时直接关掉即可

## 4. 内核选择与有线网卡

**实测结论**：

| 内核 | YT6801 驱动 | 说明 |
| --- | --- | --- |
| 6.18.52（nixpkgs 默认） | ❌ 无 | `modinfo dwmac-motorcomm` 报 not found，PCI 设备无绑定驱动 |
| 7.2.6（`linuxPackages_latest`） | ✅ 有 | `CONFIG_DWMAC_MOTORCOMM=m`，主线原生 |
| cachyos 7.2.4 | ✅ 有 | 同样带 `CONFIG_DWMAC_MOTORCOMM=m` |

裕太微 YT6801 的驱动是 stmmac 的 glue 驱动 `dwmac-motorcomm`，由 Yao Zi 提交、2026 年 1 月进 net-next、随 Linux 7.0 发布。它只提供基本网络功能，**不支持 WoL / RSS / LED**。

因此本配置选择 `pkgs.linuxPackages_latest`，省掉一个 DKMS 模块。如果坚持用 6.18 LTS，需要改成：

```nix
boot = {
  kernelPackages = pkgs.linuxPackages; # 6.18
  extraModulePackages = [ config.boot.kernelPackages.yt6801 ];
};
```

nixpkgs 里有 `yt6801-1.0.30` 这个包（对应 nixos-hardware 中 TUXEDO 同模具模块的用法），但它是 DKMS 风格，内核升级时有编译失败的历史（曾在内核 6.16 上失败）。

**装机时注意**：NixOS 安装 ISO 用的是默认内核，有线网口在安装环境里大概率不可用，请靠 Wi-Fi 联网（MT7922 实测可用）。

## 5. 盒盖睡眠

### 现状

- 平台只支持 **s2idle**（modern standby），没有 S3
- systemd 默认 `HandleLidSwitch=suspend`，所以合盖本来就会睡；真正要修的是上面那条 `acpi.ec_no_wakeup=1`
- `default.nix` 里显式写出意图（见 [default.nix](./default.nix)）：

```nix
services.logind.settings.Login = {
  HandleLidSwitch = "suspend";
  HandleLidSwitchExternalPower = "suspend";
  HandleLidSwitchDocked = "ignore";   # 插外接屏时合盖不睡
};
```

### 装好后的验证顺序

```bash
cat /sys/power/mem_sleep          # 应为 s2idle
systemctl suspend                 # 或直接合盖
```

1. 是否**立刻**醒？如果立刻醒 → 检查 `acpi.ec_no_wakeup=1` 是否真的生效（`cat /proc/cmdline`）
2. 唤醒后键盘/触摸板是否正常？不正常 → 按第 3 节加 `i8042.*`
3. 待机耗电是否异常？用 `amd-debug-tools` 里的 `amd-s2idle` 跑一次基线报告（nixpkgs 里有 `pkgs.amd-debug-tools`）

s2idle 待机耗电偏高是 Phoenix/Hawk Point 平台通病（Framework、ThinkPad AMD 也有大量同类报告），属于预期范围。

### 想加 hibernate？

本配置留了 32 GB 磁盘 swap（按内存大小给），够 hibernate 用，但**没有**启用 suspend-then-hibernate。需要的话可以自己加：

```nix
systemd.sleep.settings.Sleep = {
  AllowSuspendThenHibernate = "yes";
  HibernateDelaySec = "2h";
};
# 然后 HandleLidSwitch = "suspend-then-hibernate"
```

## 6. 磁盘与持久化

- 磁盘用稳定路径引用：`/dev/disk/by-id/nvme-CT1000P3PSSD8_24364AD5D8E0`（不要用 `/dev/nvme0n1`）
- 布局沿用之前的安装：1 GiB ESP + LUKS（名为 `crypted`）+ Btrfs 池，根分区是 tmpfs
- 根分区重启即清空，需要保留的数据由 Preservation 统一放进 `/persistent`；`hardware'.persistence.enable` 打开后，各功能模块自己声明要持久化的目录
- 重装会清空磁盘上现有的 `disk-main-ESP` / `disk-main-luks` 分区，**先备份**

## 7. 装机步骤

1. BIOS：开机连按 `Esc` 进 UEFI 关闭 Secure Boot；`Del` 出启动菜单选 U 盘
2. 用 NixOS unstable 安装介质启动，`nmtui` 连 Wi-Fi
3. 确认磁盘：`lsblk -o NAME,SIZE,MODEL,SERIAL` 与 `/dev/disk/by-id/`
4. 取 [docs/example/luks-btrfs-subvolumes.nix](../../../docs/example/luks-btrfs-subvolumes.nix) 作为 `disko.nix`，`device` 改成上面的 by-id 路径
5. 分区并挂载：

   ```bash
   sudo nix --experimental-features "nix-command flakes" \
     run github:nix-community/disko/latest -- \
     --mode destroy,format,mount ./disko.nix
   findmnt -R /mnt
   ```

6. 生成硬件配置并合并差异：

   ```bash
   sudo nixos-generate-config --no-filesystems --root /mnt
   ```

   只把真正需要的探测结果并进本目录的 `hardware.nix`，不要覆盖已有的 disko / 引导 / 持久化配置。

7. 安装：

   ```bash
   sudo nixos-install --root /mnt --flake .#wujie14x --no-root-password
   sudo reboot
   ```

更完整的说明见 [docs/NixOS 安装指南.md](../../../docs/NixOS%20安装指南.md)。

## 8. 当前未处理的事项

以下都能用，但需要额外折腾，暂未纳入配置：

| 事项 | 说明 |
| --- | --- |
| 风扇曲线 / 键盘背光 / 充电上限 / 性能模式 | Linux 无官方支持。可借 TUXEDO 驱动（社区 flake `sund3RRR/tuxedo-nixos` 提供 `hardware.tuxedo-drivers` / `tuxedo-control-center`）。注意 ArchWiki 记录了一个未确认的 bug：`tccd` 会把 CPU governor 反复重置为 `performance`，导致耗电增加 |
| 平台性能档位（Office/Gaming/Turbo） | 本机不是通过标准 ACPI platform profile 实现，而是十几次硬件调用，只能靠 TUXEDO Control Center 之类工具 |
| 充电上限 | 需要在 BIOS/EC 更新后用 `acpi_call` 写 EC 寄存器；部分机器有 EC 固件 bug 导致设置无效，需要先改写状态寄存器 |
| 人脸解锁 | IR 摄像头可用，可装 Howdy（NixOS 上需要自行打包） |
| 桌面环境 | 本配置有意未启用（greetd / niri / Noctalia / PipeWire / 字体 / 输入法都没开），需要时再逐项打开 |
| BIOS/EC 更新 | 官方只提供 Windows 刷写工具，可能要临时装个 Windows 或双系统 |

## 9. 参考来源

### 官方与上游

- ArchWiki 机型页（本机型最权威的资料，含兼容性表和全部修复条目）：
  <https://wiki.archlinux.org/title/Mechrevo_WUJIE14X>
- TUXEDO InfinityBook Pro 14 Gen9 AMD FAQ（同模具，`acpi.ec_no_wakeup=1` 的官方说法）：
  <https://www.tuxedocomputers.com/en/FAQ-TUXEDO-InfinityBook-Pro-14-Gen9-AMD.tuxedo>
- YT6801 驱动合入主线的补丁讨论（LWN）：
  <https://lwn.net/Articles/1046068/>
- amdgpu PSR bug（2880×1800 + Phoenix）：
  <https://gitlab.freedesktop.org/drm/amd/-/issues/3388>
- `amd-s2idle` 诊断工具文档：
  <https://github.com/superm1/amd-debug-tools/blob/master/docs/amd-s2idle.md>
- 同型号 Linux 硬件探测记录（linux-hardware.org）：
  <https://linux-hardware.org/?probe=1131e76e30>

### 社区修复与逆向

- sund3RRR/mechrevo14X-linux（本机型的修复清单：PSR、EC 唤醒、i8042、YT6801）：
  <https://github.com/sund3RRR/mechrevo14X-linux>
- w568w 的 14XA 逆向笔记（EC 寄存器、电池模式、键盘背光、性能档位）：
  <https://gist.github.com/w568w/b2fc5f9d1f4dff13efe751abec27b396>
- LongSang01/wujie14X-Linux-Driver、minortex/mech-forza-control（社区控制中心实现）：
  <https://github.com/LongSang01/wujie14X-Linux-Driver> ·
  <https://github.com/minortex/mech-forza-control>
- mechrevo-wujie14-kmod（注意是无界 14，不是 14X）：
  <https://github.com/xuwd1/mechrevo-wujie14-kmod>

### NixOS 相关

- fnune：同模具 TUXEDO 笔记本上的 NixOS 配置实践（`yt6801` + 两个内核参数）：
  <https://fnune.com/hardware/2025/07/20/nixos-on-a-tuxedo-infinitybook-pro-14-gen9-amd/>
- nixos-hardware 的 TUXEDO 同模具模块：
  <https://github.com/NixOS/nixos-hardware/blob/master/tuxedo/infinitybook/pro14/gen9/default.nix>
- nixpkgs 中的 `yt6801` 包：
  <https://github.com/NixOS/nixpkgs/tree/master/pkgs/os-specific/linux/yt6801>
- tuxedo-nixos（TUXEDO 驱动 / 控制中心的 NixOS 模块，未使用）：
  <https://github.com/sund3RRR/tuxedo-nixos>
- tuxedo-rs（更轻量的风扇控制替代方案，未使用）：
  <https://github.com/AaronErhardt/tuxedo-rs>

### 中文经验

- icyleaf：Arch Linux 勇闯机械革命暴风雪（长期使用体验、LLM/开发场景）：
  <https://icyleaf.com/gears/wujie-14x-laptop/>
- 知乎：机械革命无界 14X 暴风雪 Arch Linux 踩坑记录（`acpi.ec_no_wakeup=1` 的实测来源之一）：
  <https://zhuanlan.zhihu.com/p/730538041>
- 无界 14X 折腾 Fedora（斗战版 H255，`i8042` 组合参数）：
  <https://atomopo.me/2026/01/18/mechrevo-linux/>
- 无界 15X Pro 暴风雪 Arch 记录（hibernate 与 `amdgpu.gpu_recovery=1`）：
  <https://young-lord.github.io/posts/mechrevo-linux-2025>
- 无界 14X 固件折腾（BIOS/EC、充电上限）：
  <https://blog.deali.cn/p/jige-wujie14x-firmware-tinkering>

## 10. 本机实测命令备忘

复查硬件时可以重新跑这些命令：

```bash
cat /sys/class/dmi/id/{sys_vendor,product_name,board_name,bios_version,bios_date}
lspci -nn | grep -Ei 'vga|3d|ethernet|network|audio|usb controller'
lsusb
cat /sys/power/mem_sleep
cat /proc/acpi/wakeup
lsblk -o NAME,SIZE,FSTYPE,LABEL,PARTLABEL,MODEL
ls -l /dev/disk/by-id/ | grep nvme
cat /proc/cpuinfo | grep -m1 microcode
for h in /sys/class/hwmon/hwmon*; do echo -n "$h: "; cat "$h/name"; done
```

内存型号不在 `/sys/class/dmi/id` 里，而安装介质又没有 `dmidecode`，两种读法：

```bash
# 直接导出 SMBIOS 表（可用本地脚本解析 Type 17 结构）
base64 -w0 /sys/firmware/dmi/tables/DMI

# 或临时拉一个 dmidecode（需要先开启 experimental features）
nix --extra-experimental-features "nix-command flakes" \
  shell nixpkgs#dmidecode -c dmidecode -t 17
```
