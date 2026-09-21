# 无界 14X 暴风雪（WUJIE14XA）

本目录是这台机器的 NixOS 主机配置与排障笔记。标注 **实测** 的结论来自机器本身，其余来自社区资料，未在本机逐条验证。

## 1. 机型

```
型号      MECHREVO WUJIE14XA（无界 14X 暴风雪）
主板      WUJIE14-GX4HRXL
BIOS      N.1.14MRO50 (2025-11-13)
CPU       AMD Ryzen 7 8845HS (Phoenix / Hawk Point), 8C16T
内存       2 × 16 GB DDR5-5600，Crucial CT16G56C46S5.C8D
磁盘       Micron 2550 NVMe 1 TB (CT1000P3PSSD8)
```

同方 GX4HRXL 公模，与 TUXEDO InfinityBook Pro 14 Gen9 AMD、Slimbook EVO 14 同模具，TUXEDO 的驱动与 FAQ 基本适用。

## 2. 硬件

| 部件   | 标识                                        | 备注                                       |
| ------ | ------------------------------------------- | ------------------------------------------ |
| 无线   | MediaTek MT7922 `[14c3:7922]`               | **不是常见的 Intel AX200**，驱动 `mt7921e` |
| 蓝牙   | `13d3:3585`                                 | MT7922 的蓝牙部分                          |
| 有线   | Motorcomm YT6801 `[1f0a:6801]`              | 需要 Linux ≥ 7.0，见第 4 节                |
| 核显   | Radeon 780M `[1002:1900]`                   | 需要 PSR 修复，见第 3 节                   |
| 触摸板 | `UNIW0001:00 093A:0255`                     | 走 I2C，不是 PS/2                          |
| 声卡   | `[1002:1640]` + `[1022:15e3]`               | —                                          |
| TPM    | `/dev/tpm0`                                 | —                                          |
| 指纹   | —                                           | **不存在**，只有 IR 摄像头 `[04f2:b7dd]`   |
| USB4   | `[1022:1669]`                               | C 口一线通接显示器不可靠，优先 HDMI        |
| 传感器 | k10temp / amdgpu / nvme / BAT0 / spd5118 ×2 | —                                          |
| 睡眠   | `/sys/power/mem_sleep` = `[s2idle]`         | 无 S3，BIOS 也没有开关                     |

[hardware.nix](./hardware.nix) 的文件头有同一份清单。

## 3. 内核参数

```nix
kernelParams = [
  "acpi.ec_no_wakeup=1"
  "amdgpu.dcdebugmask=0x10"
];
```

### `acpi.ec_no_wakeup=1` — 让合盖能睡住

EC（`PNP0C09` / `INOU0000`）会发出虚假唤醒信号，不加这条时合盖瞬间就会醒。ArchWiki 机型页、TUXEDO 官方 FAQ（同模具）、sund3RRR 修复仓库给出的都是这一条。

### `amdgpu.dcdebugmask=0x10` — 解决花屏闪烁

`0x10` 禁用 Panel Self Refresh。2880×1800 eDP + Phoenix 核显的组合下 PSR 有 bug，会闪烁花屏（freedesktop.org/drm/amd#3388）。有人在此基础上再叠加 `0x2`（即 `0x12`），本机不需要。

### 明确不需要的

- `mem_sleep_default=deep`：本机没有 S3
- `i8042.*`：日志里那条 `i8042: PNP: PS/2 appears to have AUX port disabled ... boot with i8042.nopnp` 是**误报**——触摸板走 I2C，不经过 PS/2。实测唤醒后键盘和触摸板都正常
- SOF 固件参数（那是 Intel 平台的事）
- Secure Boot 相关（安装时直接关掉）

## 4. 内核选择与有线网卡

| 内核                            | YT6801 驱动                         |
| ------------------------------- | ----------------------------------- |
| 6.18.52（nixpkgs 默认，LTS）    | ❌ 无                               |
| 7.2.6（`linuxPackages_latest`） | ✅ 原生，`CONFIG_DWMAC_MOTORCOMM=m` |
| cachyos 7.2.4                   | ✅ 同上                             |

YT6801 的驱动是 stmmac 的 glue 驱动 `dwmac-motorcomm`，2026 年 1 月进 net-next、随 Linux 7.0 发布，只提供基本网络功能（无 WoL / RSS / LED）。

本配置用 `pkgs.linuxPackages_latest`。若改用 6.18 LTS，需要补 out-of-tree 模块：

```nix
boot.extraModulePackages = [ config.boot.kernelPackages.yt6801 ];
```

nixpkgs 有 `yt6801-1.0.30`，但它是 DKMS 风格，内核升级有编译失败的历史。

**安装时注意**：安装介质用的是默认内核，有线口不可用，请靠 Wi-Fi 联网。

## 5. 盒盖睡眠（实测通过）

平台只有 s2idle，systemd 默认就是合盖 suspend，真正要修的是 `acpi.ec_no_wakeup=1`。`default.nix` 里显式写出意图：

```nix
services.logind.settings.Login = {
  HandleLidSwitch = "suspend";
  HandleLidSwitchExternalPower = "suspend";
  HandleLidSwitchDocked = "ignore";   # 插外接屏时合盖不睡
};
```

两次实测：

| 方式                        | 结果                                                          |
| --------------------------- | ------------------------------------------------------------- |
| `sudo rtcwake -m mem -s 30` | 硬件睡 29.9 秒，RTC 准时唤醒                                  |
| 合盖 5 分钟                 | `Lid closed.` → 1 秒内进入 s2idle → 睡满 5 分 3 秒 → 开盖唤醒 |

两次之后 `suspend_stats` 是 `success 2`、`fail 0`。要点：

- 没有出现"合盖立刻醒"，`acpi.ec_no_wakeup=1` 确实生效
- 硬件睡眠时长与合盖到开盖的间隔几乎相等，中间没有异常唤醒
- **开盖即可唤醒**，不需要按电源键（键盘唤不醒：内核为规避固件 bug 执行了 `atkbd serio0: Disabling IRQ1 wakeup source`）
- 恢复后设备全部正常：amdgpu SMU、`dwmac-motorcomm enp1s0`、nvme 队列、Wi-Fi 重连

排查：

```bash
cat /sys/power/mem_sleep                          # 应为 s2idle
cat /sys/power/suspend_stats/{success,last_hw_sleep}
journalctl -b | grep -iE 'lid|suspend entry|suspend exit'
sudo rtcwake -m mem -s 30                         # 定时唤醒的安全测法
```

待机耗电偏高是 Phoenix 平台通病。本机只测过 5 分钟，长时间待机还没摸底，需要时用 `pkgs.amd-debug-tools` 的 `amd_s2idle` 跑基线报告。

**想加 hibernate**：配置留了 32 GB swap 但没有启用 suspend-then-hibernate，需要时加

```nix
systemd.sleep.settings.Sleep.AllowSuspendThenHibernate = "yes";
# 再把 HandleLidSwitch 改成 "suspend-then-hibernate"
```

## 6. 磁盘与持久化

- 磁盘用 by-id 路径引用：`/dev/disk/by-id/nvme-CT1000P3PSSD8_24364AD5D8E0`
- 布局：1 GiB ESP + LUKS（`crypted`）+ Btrfs 池，根分区是 tmpfs
- 根分区重启即清空，要保留的数据由 Preservation 放进 `/persistent`，各功能模块自己声明条目
- 重装会清空磁盘上的现有分区，**先备份**

## 7. 装机步骤

1. BIOS：连按 `Esc` 关掉 Secure Boot，`Del` 选启动设备
2. 用 NixOS unstable 介质启动，`nmtui` 连 Wi-Fi
3. 取 [docs/example/luks-btrfs-subvolumes.nix](../../../docs/example/luks-btrfs-subvolumes.nix) 作 `disko.nix`，把 `device` 改成上面的 by-id 路径，然后：

```bash
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- --mode destroy,format,mount ./disko.nix

# 只把需要的探测结果并进本目录的 hardware.nix，别整份覆盖
sudo nixos-generate-config --no-filesystems --root /mnt

sudo nixos-install --root /mnt --flake .#wujie14x --no-root-password
```

完整说明见 [docs/NixOS 安装指南.md](../../../docs/NixOS%20安装指南.md)。

## 8. 已知警告（都无需处理）

| 日志                                                                                                       | 判断                                                           |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| `ACPI BIOS Error: Failure creating named object [\_SB.PCI0.GPP6.WLAN._DSM]`（连同 `_S0W`、`_PRW` 共 4 条） | BIOS 自身的 bug，GPP6 是 Wi-Fi 总线；TUXEDO FAQ 确认不影响运行 |
| `i8042: PNP: PS/2 appears to have AUX port disabled`                                                       | 误报，见第 3 节                                                |
| `atkbd serio0: Disabling IRQ1 wakeup source to avoid platform firmware bug`                                | 内核规避固件 bug，键盘不能唤醒，开盖可以                       |
| `kvm_amd: Cannot enable x2AVIC, AVIC is unsupported`                                                       | BIOS 未开 AVIC，只影响嵌套虚拟化性能                           |
| `asus_wmi: ASUS Management GUID not found`                                                                 | 通用 WMI 探测噪音                                              |
| `Bluetooth: hci0: HCI Enhanced Setup Synchronous Connection ... not supported`                             | MT7922 固件的小瑕疵                                            |
| `workqueue: name exceeds WQ_NAME_LEN`                                                                      | amdgpu 的 HDMI FRL 工作队列名过长                              |
| `Failed to adjust io pressure threshold: Device or resource busy`                                          | systemd 用户实例设置 IO 压力阈值的噪音                         |
| `ucsi_acpi USBC000:00: failed to re-enable notifications (-110)`                                           | 恢复时 USB-C 通知超时，孤立事件                                |
| `NetworkManager: device (p2p-dev-wlp2s0): error setting IPv4 forwarding to '0'`                            | NetworkManager 常见噪音                                        |

### sshd 首次启动失败

安装后的**第一次**启动，sshd 抢在 `/etc` 就绪之前启动，10 秒内失败 6 次、触发 `StartLimitBurst=5` 后放弃：

```
sshd: /etc/ssh/sshd_config: No such file or directory
sshd.service: Failed with result 'start-limit-hit'
```

本地登录跑一次 `sudo nixos-rebuild switch` 重建 `/etc` 即可恢复。**后续重启没有重现**（2026-09-21 验证：一次启动成功）。如果反复出现，放宽启动限制让 sshd 自己重试：

```nix
systemd.services.sshd = { startLimitIntervalSec = 300; startLimitBurst = 20; };
```

## 9. 未纳入配置的事项

| 事项                                      | 说明                                                                                                                                                                 |
| ----------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 风扇曲线 / 键盘背光 / 充电上限 / 性能档位 | Linux 无官方支持，需 TUXEDO 驱动（社区 flake `sund3RRR/tuxedo-nixos`）。ArchWiki 记录了一个未确认的 bug：`tccd` 会把 CPU governor 反复重置为 `performance`，增加耗电 |
| 充电上限                                  | 需在 BIOS/EC 更新后用 `acpi_call` 写 EC 寄存器；部分机器有 EC 固件 bug 导致设置无效                                                                                  |
| 人脸解锁                                  | IR 摄像头可用，Howdy 需要自行打包                                                                                                                                    |
| 桌面环境                                  | 有意未启用（greetd / niri / Noctalia / PipeWire / 字体 / 输入法）                                                                                                    |
| BIOS/EC 更新                              | 官方只提供 Windows 刷写工具                                                                                                                                          |

## 10. 参考来源

**官方与上游**

- [ArchWiki 机型页](https://wiki.archlinux.org/title/Mechrevo_WUJIE14X) — 本机型最权威的资料，含兼容性表和全部修复条目
- [TUXEDO InfinityBook Pro 14 Gen9 AMD FAQ](https://www.tuxedocomputers.com/en/FAQ-TUXEDO-InfinityBook-Pro-14-Gen9-AMD.tuxedo) — 同模具，`acpi.ec_no_wakeup=1` 的官方说法
- [YT6801 驱动合入主线的补丁讨论（LWN）](https://lwn.net/Articles/1046068/)
- [amdgpu PSR bug（2880×1800 + Phoenix）](https://gitlab.freedesktop.org/drm/amd/-/issues/3388)
- [`amd_s2idle` 诊断文档](https://github.com/superm1/amd-debug-tools/blob/master/docs/amd-s2idle.md)
- [同型号硬件探测记录](https://linux-hardware.org/?probe=1131e76e30)

**社区修复与逆向**

- [sund3RRR/mechrevo14X-linux](https://github.com/sund3RRR/mechrevo14X-linux) — 本机型修复清单：PSR、EC 唤醒、i8042、YT6801
- [w568w 的 14XA 逆向笔记](https://gist.github.com/w568w/b2fc5f9d1f4dff13efe751abec27b396) — EC 寄存器、电池模式、键盘背光、性能档位
- [LongSang01/wujie14X-Linux-Driver](https://github.com/LongSang01/wujie14X-Linux-Driver) · [minortex/mech-forza-control](https://github.com/minortex/mech-forza-control) — 社区控制中心实现
- [mechrevo-wujie14-kmod](https://github.com/xuwd1/mechrevo-wujie14-kmod) — 注意是无界 14，不是 14X

**NixOS 相关**

- [fnune：同模具 TUXEDO 笔记本上的 NixOS 实践](https://fnune.com/hardware/2025/07/20/nixos-on-a-tuxedo-infinitybook-pro-14-gen9-amd/) — `yt6801` 与两个内核参数
- [nixos-hardware 的 TUXEDO 同模具模块](https://github.com/NixOS/nixos-hardware/blob/master/tuxedo/infinitybook/pro14/gen9/default.nix)
- [nixpkgs 中的 `yt6801` 包](https://github.com/NixOS/nixpkgs/tree/master/pkgs/os-specific/linux/yt6801)
- [sund3RRR/tuxedo-nixos](https://github.com/sund3RRR/tuxedo-nixos) · [tuxedo-rs](https://github.com/AaronErhardt/tuxedo-rs) — 均未使用

**中文经验**

- [icyleaf：Arch Linux 勇闯机械革命暴风雪](https://icyleaf.com/gears/wujie-14x-laptop/) — 长期使用体验与开发场景
- [知乎：机械革命无界 14X 暴风雪 Arch Linux 踩坑记录](https://zhuanlan.zhihu.com/p/730538041)
- [无界 14X 折腾 Fedora](https://atomopo.me/2026/01/18/mechrevo-linux/) — 斗战版 H255 的 `i8042` 组合参数
- [无界 15X Pro 暴风雪 Arch 记录](https://young-lord.github.io/posts/mechrevo-linux-2025) — hibernate 与 `amdgpu.gpu_recovery=1`
- [无界 14X 固件折腾](https://blog.deali.cn/p/jige-wujie14x-firmware-tinkering) — BIOS/EC、充电上限

## 11. 硬件复查命令

```bash
cat /sys/class/dmi/id/{sys_vendor,product_name,board_name,bios_version}
lspci -nn | grep -Ei 'vga|3d|ethernet|network|audio'
cat /sys/power/mem_sleep
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,MODEL
ls -l /dev/disk/by-id/ | grep nvme
```

内存型号不在 `/sys/class/dmi/id` 里，而安装介质又没有 `dmidecode`，两种读法：

```bash
base64 -w0 /sys/firmware/dmi/tables/DMI   # 导出 SMBIOS 表，按 Type 17 结构解析

nix --extra-experimental-features "nix-command flakes" \
  shell nixpkgs#dmidecode -c dmidecode -t 17
```
