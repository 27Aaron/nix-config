# 待办

本机的待办与有意未纳入配置的事项。已经验证的结论见 [README.md](./README.md)，噪音与排障见 [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)。

## 清单

- [ ] 硬件控制之一：TUXEDO 驱动（风扇曲线、性能档位）
- [ ] 硬件控制之二：EC 寄存器（键盘背光、充电上限）

## 硬件控制

Linux 下这些功能都没有官方支持，按实现路径分两条线。

### TUXEDO 驱动：风扇曲线与性能档位

本机是 TUXEDO InfinityBook Pro 14 Gen9 AMD 的同模具，可以直接借它的驱动：

- [sund3RRR/tuxedo-nixos](https://github.com/sund3RRR/tuxedo-nixos) 提供 `hardware.tuxedo-drivers` 与 `tuxedo-control-center` 模块
- [tuxedo-rs](https://github.com/AaronErhardt/tuxedo-rs) 更轻量，能设风扇曲线，但没有系统托盘，也不能按"插电 / 电池"自动切档
- **注意**：ArchWiki 记录了一个未确认的 bug——TCC 的 `tccd` 会把 CPU governor 反复重置为 `performance`，增加耗电
- 性能档位（Office / Gaming / Turbo）在本机**不是标准 ACPI platform profile**，而是十几次硬件调用，目前只有 TUXEDO Control Center 能可靠切换

### EC 寄存器：键盘背光与充电上限

需要用 `acpi_call` 直接写 EC 寄存器（本机已是官方最新的 MRO50 / EC 2.12）：

- 键盘背光：`\_SB.INOU.ECRW 0x078c <值>`，`0x11` 关、`0x31` 低、`0x51` 高；Fn+F6 本身可以循环三档
- 充电上限：`\_SB.INOU.ECRW 0x07b9 <阈值>`，阈值取 60–100
- **坑**：充电限制的 bug 在 EC 2.08 只修了一半，**即使最新固件（MRO50 / EC 2.12）在很多机器上仍然不生效**——写 `0x07b9` 返回成功，但 EC 只在状态寄存器 `0x07c3`/`0x0770` 为 4/5 时才启用限制，需要先临时把 `0x07c3` 改成 `0x04` 两秒再改回。EC 地址表、机制分析和现成脚本见 [w568w 的修复记录](https://gist.github.com/w568w/957976b59906e0ce5d6c13ad342e1593)
