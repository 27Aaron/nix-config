# 待办

本机的待办与有意未纳入配置的事项。已经验证的结论见 [README.md](./README.md)，噪音与排障见 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)。

## 清单

- [ ] 测量长时待机耗电：拔电合盖放 1–2 小时
- [ ] 接入 Gaze 人脸解锁
- [ ] 接入桌面环境（greetd / niri / Noctalia / PipeWire / 字体 / 输入法）
- [ ] 风扇曲线 / 键盘背光 / 充电上限 / 性能档位（需 TUXEDO 驱动）
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
- 官方只为 GNOME / KDE / Hyprland 提供桌面集成（扩展、`gaze-kde`、`gaze-hyprlock`）；niri 属于"其他 PAM 桌面"，只能用基础 PAM 模块，锁屏集成要自己接
- 模块选项与 home-manager 用法见 [Nix & NixOS 指南](https://gaze.gundulabs.com/guide/nixos.html)

## 未纳入配置的硬件功能

| 事项                                      | 说明                                                                                                                                                                  |
| ----------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 风扇曲线 / 键盘背光 / 充电上限 / 性能档位 | Linux 无官方支持，需 TUXEDO 驱动（社区 flake `sund3RRR/tuxedo-nixos`）。ArchWiki 记录了一个未确认的 bug：`tccd` 会把 CPU governor 反复重置为 `performance`，增加耗电 |
| 充电上限                                  | 需在 BIOS/EC 更新后用 `acpi_call` 写 EC 寄存器；部分机器有 EC 固件 bug 导致设置无效                                                                                   |
| BIOS/EC 更新                              | 官方只提供 Windows 刷写工具，可能要临时装 Windows 或双系统                                                                                                            |

## 桌面环境

当前有意未启用（greetd / niri / Noctalia / PipeWire / 字体 / 输入法），需要时逐项打开 `desktop'` 下的模块。
