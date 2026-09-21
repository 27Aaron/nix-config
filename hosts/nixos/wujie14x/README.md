# 无界 14X 暴风雪（WUJIE14XA）

本目录是这台机器的 NixOS 主机配置。硬件清单与结论来自本机实测，其余来自社区资料。

排障与已知噪音见 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)，待办与未纳入配置的事项见 [TODO.md](./TODO.md)。

## 1. 机型

| 项   | 值                                               |
| ---- | ------------------------------------------------ |
| 型号 | MECHREVO WUJIE14XA（无界 14X 暴风雪）            |
| 主板 | WUJIE14-GX4HRXL                                  |
| BIOS | N.1.14MRO50 (2025-11-13)                         |
| CPU  | AMD Ryzen 7 8845HS (Phoenix / Hawk Point), 8C16T |
| 内存 | 2 × 16 GB DDR5-5600，Crucial CT16G56C46S5.C8D    |
| 磁盘 | Micron 2550 NVMe 1 TB (CT1000P3PSSD8)            |

无线、有线、触摸板、传感器等完整清单在 [hardware.nix](./hardware.nix) 的文件头。

BIOS 更新工具官方只提供 Windows 版（`.EXE`）：[下载 N.1.14MRO50](https://driver.mechrevo.com/d.mechrevo.com/driver/MECHREVO2024/WJ14X8845HS/GXxHXxxN114MRO50_CAP.EXE)（来源：[w568w 的 gist 讨论](https://gist.github.com/w568w/b2fc5f9d1f4dff13efe751abec27b396?permalink_comment_id=6147538#gistcomment-6147538)）。

同方 GX4HRXL 公模，与 TUXEDO InfinityBook Pro 14 Gen9 AMD、Slimbook EVO 14 同模具，TUXEDO 的驱动与 FAQ 基本适用。

## 2. 内核参数

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
- `i8042.*`：那条 PS/2 AUX 警告是误报，触摸板走 I2C，见 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- SOF 固件参数（那是 Intel 平台的事）
- Secure Boot 相关（安装时直接关掉）

## 3. 内核选择

用 `pkgs.linuxPackages_latest`：有线网卡 YT6801 从 Linux 7.0 起由主线自带（`dwmac-motorcomm`），不需要额外的 out-of-tree 模块；改用 6.18 LTS 则要补 `boot.extraModulePackages = [ config.boot.kernelPackages.yt6801 ]`。

## 4. 盒盖睡眠

平台只有 s2idle（无 S3）。合盖走 suspend-then-hibernate：先 s2idle（开盖秒醒），睡满 `HibernateDelaySec` 后自动转 hibernate；**插电时倒计时不启动**，一直保持 suspend。前提是 `acpi.ec_no_wakeup=1`，否则合盖会立刻醒。

`default.nix` 里的配置：

```nix
systemd.sleep.settings.Sleep = {
  AllowSuspendThenHibernate = "yes";
  HibernateDelaySec = "1h";
  HibernateOnACPower = "no";          # 插电时不倒计时
};

services.logind.settings.Login = {
  HandleLidSwitch = "suspend-then-hibernate";
  HandleLidSwitchExternalPower = "suspend-then-hibernate";
  HandleLidSwitchDocked = "ignore";   # 插外接屏时合盖不睡
};
```

两种状态都已实测通过：suspend 能睡住、开盖秒醒；hibernate 会写盘断电，按电源键后经引导 + LUKS 解锁恢复内存。实测数据、验证方法，以及一个已知限制（NPU 驱动会让休眠失败）见 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)。

## 5. 桌面环境

greetd 自动登录进 Niri，配 Noctalia 外壳、PipeWire 音频、fcitx5 输入法（雾凇拼音）、字体、主题与光标；应用有 kitty、Firefox、Zed，另加 nautilus / mpv 等桌面基础应用。开关都在 [default.nix](./default.nix) 里，模块在 `modules/nixos/desktop/` 下。

niri 的键位与输出缩放不在此仓库（`~/.config/niri/config.kdl` 手工维护），首次进桌面用上游默认键位。

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

## 8. 参考来源

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
