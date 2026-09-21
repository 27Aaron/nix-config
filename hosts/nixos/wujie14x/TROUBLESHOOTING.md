# 排障笔记

本机的实测记录、启动噪音判断与排障命令。配置依据见 [README.md](./README.md)，待办见 [TODO.md](./TODO.md)。

## 睡眠：实测记录与排障

### 实测记录

| 方式                        | 结果                                                          |
| --------------------------- | ------------------------------------------------------------- |
| `sudo rtcwake -m mem -s 30` | 硬件睡 29.9 秒，RTC 准时唤醒                                  |
| 合盖 5 分钟（插电）         | `Lid closed.` → 1 秒内进入 s2idle → 睡满 5 分 3 秒 → 开盖唤醒 |
| 合盖 23 分钟（电池）        | 睡满 23 分 24 秒，中间没有唤醒                                |

三次之后 `suspend_stats` 是 `success 3`、`fail 0`。要点：

- 没有出现"合盖立刻醒"，`acpi.ec_no_wakeup=1` 确实生效
- 硬件睡眠时长与合盖到开盖的间隔几乎相等，中间没有异常唤醒
- **开盖即可唤醒**，不需要按电源键（键盘唤不醒：内核为规避固件 bug 执行了 `atkbd serio0: Disabling IRQ1 wakeup source`）
- 恢复后设备全部正常：amdgpu SMU、`dwmac-motorcomm enp1s0`、nvme 队列、Wi-Fi 重连

待机耗电：电池供电睡 23 分钟后 `charge_now` 仍等于满电值，而 BMS 的电量分辨率是 1%（0.052 Ah ≈ 0.85 Wh），所以**待机功耗 < 2.2 W**。要精确值需要睡 1–2 小时，见 [TODO.md](./TODO.md)。

### 排障

```bash
cat /sys/power/mem_sleep                          # 应为 s2idle
cat /sys/power/suspend_stats/{success,last_hw_sleep}
journalctl -b | grep -iE 'lid|suspend entry|suspend exit'
sudo rtcwake -m mem -s 30                         # 定时唤醒的安全测法
```

- 合盖立刻醒 → 检查 `acpi.ec_no_wakeup=1` 是否真的在 `cat /proc/cmdline` 里
- 唤醒后键盘或触摸板失灵 → 本机不需要 `i8042.*`，先查别的原因
- 唤醒后黑屏 → 可尝试 `amdgpu.gpu_recovery=1`（来自 15X Pro 的记录，本机未遇到）

## 已知警告（都无需处理）

| 日志                                                                                                       | 判断                                                                             |
| ---------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `ACPI BIOS Error: Failure creating named object [\_SB.PCI0.GPP6.WLAN._DSM]`（连同 `_S0W`、`_PRW` 共 4 条） | BIOS 自身的 bug，GPP6 是 Wi-Fi 总线；TUXEDO FAQ 确认不影响运行                   |
| `i8042: PNP: PS/2 appears to have AUX port disabled ... boot with i8042.nopnp`                             | **误报**，触摸板走 I2C 不经过 PS/2；因此不需要 `i8042.nopnp`/`nomux`/`noloop`    |
| `atkbd serio0: Disabling IRQ1 wakeup source to avoid platform firmware bug`                                | 内核规避固件 bug，键盘不能唤醒，开盖可以                                         |
| `kvm_amd: Cannot enable x2AVIC, AVIC is unsupported`                                                       | BIOS 未开 AVIC，只影响嵌套虚拟化性能                                             |
| `asus_wmi: ASUS Management GUID not found`                                                                 | 通用 WMI 探测噪音                                                                |
| `Bluetooth: hci0: HCI Enhanced Setup Synchronous Connection ... not supported`                             | MT7922 固件的小瑕疵                                                              |
| `workqueue: name exceeds WQ_NAME_LEN`                                                                      | amdgpu 的 HDMI FRL 工作队列名过长                                                |
| `Failed to adjust io pressure threshold: Device or resource busy`                                          | systemd 用户实例设置 IO 压力阈值的噪音                                           |
| `ucsi_acpi USBC000:00: failed to re-enable notifications (-110)`                                           | USB-C 通知超时（ETIMEDOUT），插拔 C 口设备与睡眠恢复都会触发，见下一节                                     |
| `ACPI BIOS Error: Could not resolve symbol [\_SB.ACDC.RTAC]`（连带 `Aborting method \_SB.PEP._DSM`）       | 只在**电池供电**睡眠唤醒时出现，插电时不出现；BIOS 的电源管理方法失败，不影响恢复 |
| `pcieport 0000:00:08.1: PME: Spurious native interrupt!`                                                   | PCIe 电源管理事件的虚假中断，s2idle 唤醒时常见                                   |
| `NetworkManager: device (p2p-dev-wlp2s0): error setting IPv4 forwarding to '0'`                            | NetworkManager 常见噪音                                                          |

## USB-C 外接显示时的 amdgpu 报错（待排查）

实测 C 口一线通能正常出图，但插上显示器时 amdgpu 会打出一批报错。下面三条都是上游已知问题，不是本机特有，后续逐个排查。

### LTTPR 链路训练报错

```
amdgpu 0000:64:00.0: [drm] *ERROR* lttpr_caps phy_repeater_cnt is 0x0, forcing it to 0x80.
amdgpu 0000:64:00.0: [drm] *ERROR* LTTPR count is nonzero but invalid lane count reported. Assuming no LTTPR present.
```

LTTPR（Link Training Tunable PHY Repeater）是 DP 链路里的可调中继器，常见于扩展坞和长线缆。驱动读到的对端能力数据不合规范，于是强制降级——设成 `0x80` 并假设链路里没有 LTTPR，降级后链路仍能协商成功。

- 触发与否取决于**线缆 + 显示器/坞的组合**：[Arch BBS 帖子](https://bbs.archlinux.org/viewtopic.php?id=311412)里有人用两个便携屏测试，两根线都报错、第三根线完全正常
- 同一帖里有人报告，某些设备会让这组错误每秒重复一次，并造成最长 1 秒的卡顿
- 本机 2026-09-21 实测：插上时一秒内刷了 9 条，显示器工作正常

### compbuf 寄存器超时

```
amdgpu 0000:64:00.0: [drm] REG_WAIT timeout 1us * 100 tries - dcn31_program_compbuf_size line:141
WARNING: drivers/gpu/drm/amd/amdgpu/../display/dc/hubbub/dcn31/dcn31_hubbub.c:151 at dcn31_program_compbuf_size+0xd1/0x230 [amdgpu]
Workqueue: events_highpri dm_irq_work_func [amdgpu]
```

热插拔中断触发显示带宽重算时，DCN 3.1 的压缩缓冲区寄存器等 100μs 没就绪。调用链是 `handle_hpd_irq_helper` → `drm_client_hotplug` → `dc_commit_streams` → `dcn20_optimize_bandwidth` → `dcn31_program_compbuf_size`。

- 上游已知：[CachyOS issue #810](https://github.com/CachyOS/linux-cachyos/issues/810)，标签是 `upstream`；报告者试过 `amdgpu.dcfeaturemask=0x0` 和 `amdgpu.sg_display=0`，都拦不住
- WARNING 不是崩溃，驱动会继续走完流程

### 改善方向

- LTTPR：换一根 USB-IF 认证的 C 线或雷电 3/4 线，这是社区里唯一被证实有效的办法
- compbuf：暂时没有已知的内核参数能消除

