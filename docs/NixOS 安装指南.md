# NixOS 安装指南

本文档介绍如何从 NixOS 安装介质启动，使用独立的 Disko 配置创建文件系统，并通过本仓库的 Flake 安装 `elaina`。

> [!CAUTION]
> Disko 会清空目标磁盘上的所有分区和数据。执行前请备份数据，并再次确认目标磁盘。

## Disko 配置

仓库的 `docs/example/` 目录提供两份可以独立使用的 Disko 配置，同时也是当前磁盘布局的备份：

- [`luks-btrfs-subvolumes.nix`](./example/luks-btrfs-subvolumes.nix)：LUKS 加密，带 swap
- [`btrfs-subvolumes.nix`](./example/btrfs-subvolumes.nix)：无加密，无 swap

选择其中一份，下载为 `disko.nix`（以下以 LUKS 版本为例）：

```bash
curl -o disko.nix https://raw.githubusercontent.com/27Aaron/Dotfiles/main/docs/example/luks-btrfs-subvolumes.nix
```

安装前确认配置中的 `device` 与目标磁盘一致：

```bash
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL
ls -l /dev/disk/by-id/
```

## 使用 Disko 安装文件系统

进入 `disko.nix` 所在目录并执行：

```bash
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount ./disko.nix
```

Disko 会要求确认清空磁盘；使用 LUKS 版本时还会交互式询问密码。完成后确认文件系统已经挂载到 `/mnt`：

```bash
findmnt -R /mnt
lsblk -f
```

## 生成配置并安装系统

克隆仓库并进入仓库根目录：

```bash
git clone https://github.com/27Aaron/Dotfiles.git ~/nix-config
cd ~/nix-config
```

生成不包含文件系统定义的硬件配置：

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

检查 `/mnt/etc/nixos/hardware-configuration.nix`，将仍然需要的硬件探测结果合并到 `hosts/nixos/elaina/hardware.nix`，不要覆盖已有的 Disko、持久化和引导配置。

确认 `vars/default.nix` 中的用户名、密码哈希、SSH 公钥和默认时区，以及 `hosts/nixos/<主机名>/default.nix` 中的系统状态版本正确，然后安装系统：

```bash
sudo nixos-install \
  --root /mnt \
  --flake .#elaina \
  --no-root-password
```

安装完成后重启并拔出安装介质：

```bash
sudo reboot
```

使用 LUKS 版本时，启动需要输入 LUKS 密码，然后使用 `vars/default.nix` 中配置的账户登录。

> [!IMPORTANT]
> 根文件系统使用 tmpfs，系统设计为将需要保留的数据存储到 `/persistent`；未持久化的数据会在重启后消失。

## 后续维护

仓库中的 `justfile` 提供以下命令（`just` 和 `nh` 已由配置安装，flake 路径固定为 `~/nix-config`）：

```bash
just switch  # 构建并应用当前主机配置
just check   # 检查格式、未使用声明和所有主机求值
just update  # 更新 flake.lock
just gc      # 清理旧的 generation 及无引用 Store 路径
```

CI 只检查格式、未使用声明和 Nix 语法。更新配置或依赖后，请在本地运行 `just check`，通过后再执行 `just switch`。

## 参考资料

- [Disko](https://github.com/nix-community/disko)
- [Disko Quickstart](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
- [Disko 示例](https://github.com/nix-community/disko/tree/master/example)
- [Preservation](https://github.com/nix-community/preservation)
