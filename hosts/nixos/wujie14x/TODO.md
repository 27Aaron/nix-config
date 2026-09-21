# 待办

本机的待办与有意未纳入配置的事项。已经验证的结论见 [README.md](./README.md)，噪音与排障见 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)。

## 清单

- [ ] 测量长时待机耗电：拔电合盖放 1–2 小时
- [ ] 接入 Gaze 人脸解锁
- [ ] 接入桌面环境（greetd / niri / Noctalia / PipeWire / 字体 / 输入法）
- [ ] 硬件控制之一：TUXEDO 驱动（风扇曲线、性能档位）
- [ ] 硬件控制之二：EC 寄存器（键盘背光、充电上限）
- [ ] 排查 USB-C 外接显示时的 amdgpu 报错
- [ ] BIOS/EC 更新（官方只提供 Windows 刷写工具）

## 长时待机耗电

电池供电睡 23 分钟只得出"< 2.2 W"这个上界，受 BMS 1% 分辨率所限。想拿精确值，拔电合盖放 1–2 小时再看 `charge_now`；需要时用 `pkgs.amd-debug-tools` 的 `amd_s2idle` 跑基线报告。

## 人脸解锁：Gaze

IR 摄像头（`04f2:b7dd`）可用，计划用 [Gaze](https://gaze.gundulabs.com/guide/installation.html)（Gundu Labs）。它**官方提供 Nix flake 和 NixOS 模块**，不需要像 Howdy 那样自己打包：

```nix
# flake inputs
inputs.gaze.url = "github:GunduLabs/gaze";

# NixOS 配置
imports = [ inputs.gaze.nixosModules.default ];
services.gaze = {
  enable = true;
  gui.enable = true;
};
```

需要注意的：

- 要求 CPU 支持 **AVX2**（8845HS 满足）；缺 AVX2 时 `gazed` 会直接退出，没有降级模式
- 装完 `sudo reboot` 一次，再用 `systemctl status gazed`、`gaze doctor` 验证
- 注册人脸 `gaze add-face default`，测试 `gaze auth --verbose`
- 官方只为 GNOME / KDE / Hyprland 提供桌面集成（扩展、`gaze-kde`、`gaze-hyprlock`）；niri 属于"其他 PAM 桌面"，只能用基础 PAM 模块，**锁屏集成要自己接**，而且依赖下面的桌面环境先落地
- 模块选项与 home-manager 用法见 [Nix & NixOS 指南](https://gaze.gundulabs.com/guide/nixos.html)

## 硬件控制

Linux 下这些功能都没有官方支持，按实现路径分两条线。

### TUXEDO 驱动：风扇曲线与性能档位

本机是 TUXEDO InfinityBook Pro 14 Gen9 AMD 的同模具，可以直接借它的驱动：

- [sund3RRR/tuxedo-nixos](https://github.com/sund3RRR/tuxedo-nixos) 提供 `hardware.tuxedo-drivers` 与 `tuxedo-control-center` 模块
- [tuxedo-rs](https://github.com/AaronErhardt/tuxedo-rs) 更轻量，能设风扇曲线，但没有系统托盘，也不能按"插电 / 电池"自动切档
- **注意**：ArchWiki 记录了一个未确认的 bug——TCC 的 `tccd` 会把 CPU governor 反复重置为 `performance`，增加耗电
- 性能档位（Office / Gaming / Turbo）在本机**不是标准 ACPI platform profile**，而是十几次硬件调用，目前只有 TUXEDO Control Center 能可靠切换

### EC 寄存器：键盘背光与充电上限

需要用 `acpi_call` 直接写 EC 寄存器：

- 键盘背光：`\_SB.INOU.ECRW 0x078c <值>`，`0x11` 关、`0x31` 低、`0x51` 高；Fn+F6 本身可以循环三档
- 充电上限：`\_SB.INOU.ECRW 0x07b9 <阈值>`，阈值取 60–100
- **坑**：部分机器的 EC 固件有 bug，写入返回成功但设置不生效，需要先临时把状态寄存器 `0x07c3` 改成 `0x04` 两秒再改回；动手前先把 BIOS/EC 升到 `N.1.14MRO19`（EC 2.08）或 `N.1.14MRO50`（EC 2.12）及以上

### BIOS/EC 更新

官方只提供 Windows 刷写工具，可能要临时装 Windows 或双系统。上一条的 EC 寄存器操作要求先完成这一步。

## 桌面环境

当前有意未启用（greetd / niri / Noctalia / PipeWire / 字体 / 输入法），需要时逐项打开 `desktop'` 下的模块。人脸解锁的锁屏集成依赖它先落地。
