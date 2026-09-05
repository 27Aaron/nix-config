# NixOS 安装指南

本文档介绍如何从 NixOS 安装介质启动，先用独立的 Disko 配置完成分区和格式化，再通过本仓库的 Flake 安装主机 `elaina`。

> [!CAUTION]
> 下文的 Disko 命令会清空目标磁盘上的全部分区和数据。执行前请备份重要数据，并再次确认目标磁盘。

## Disko 配置

仓库的 `docs/example/` 目录提供四份可独立使用的 Disko 配置，按根分区类型分为两组：

**tmpfs 作根（当前布局，重启后根分区清空）**

- [`luks-btrfs-subvolumes.nix`](./example/luks-btrfs-subvolumes.nix)：LUKS 加密，带 swap
- [`btrfs-subvolumes.nix`](./example/btrfs-subvolumes.nix)：无加密，无 swap

**根分区落盘（btrfs 子卷 `@root`，重启后保留）**

- [`luks-btrfs-root.nix`](./example/luks-btrfs-root.nix)：LUKS 加密，带 swap
- [`btrfs-root.nix`](./example/btrfs-root.nix)：无加密，无 swap

仓库的主机配置固定按 tmpfs 根布局生成文件系统定义，推荐选择第一组；如果选择第二组，请同步调整主机配置中对应的文件系统定义。

选定后下载为 `disko.nix`（下文以 LUKS tmpfs 版为例）：

```bash
curl -o disko.nix https://raw.githubusercontent.com/27Aaron/Dotfiles/main/docs/example/luks-btrfs-subvolumes.nix
```

编辑 `disko.nix`，把 `device` 改为目标磁盘，推荐使用 `/dev/disk/by-id/` 下的稳定路径：

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

Disko 会先要求确认清空磁盘，LUKS 版本还会交互式询问加密密码。完成后确认文件系统已挂载到 `/mnt`：

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

生成不包含文件系统定义的硬件配置（文件系统定义由 Disko 和仓库配置负责）：

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
```

查看 `/mnt/etc/nixos/hardware-configuration.nix`，把仍然需要的硬件探测结果合并进 `hosts/nixos/elaina/hardware.nix`，注意不要覆盖仓库中已有的 Disko、持久化和引导配置。

安装前检查以下配置：

- `vars/default.nix`：用户名、密码哈希、SSH 公钥、默认时区
- `hosts/nixos/elaina/default.nix`：`system.stateVersion`

然后安装系统：

```bash
sudo nixos-install \
  --root /mnt \
  --flake .#elaina \
  --no-root-password
```

安装完成后重启并移除安装介质：

```bash
sudo reboot
```

使用 LUKS 版本时，开机需要先输入加密密码，再用 `vars/default.nix` 中配置的账户登录。

> [!IMPORTANT]
> 根文件系统为 tmpfs，重启即清空；需要保留的数据由持久化机制统一存放在 `/persistent`，未持久化的内容重启后会丢失。

## 后续维护

仓库的 `Justfile` 提供以下命令（`just` 和 `nh` 已随配置安装；`nh` 固定读取 `~/nix-config`，即上文的克隆路径）：

```bash
just switch  # 构建并应用当前主机配置
just check   # 检查格式、未使用声明和所有主机求值
just update  # 更新 flake.lock
just gc      # 交互式清理旧 generation 及无引用 Store 路径
```

仓库不设远程 CI 检查，GitHub 上仅有 issue/PR 的标签和依赖更新自动化。修改配置或依赖后，先在本地运行 `just check`，通过后再执行 `just switch`。

### 中文输入法

桌面使用 Fcitx5 中州韵，默认方案为万象标准版全拼。首次构建会下载约 420 MB 的语法模型。

候选窗口使用 Ayaya Day / Night 皮肤，横向排列，字体为霞鹜文楷、思源黑体后备。皮肤跟随系统深浅色偏好自动切换；只更换壁纸或应用主题而未改变系统深浅色偏好时，输入法皮肤不会切换。

执行 `just switch` 后，注销并重新登录，在输入法托盘菜单中选择「重新部署」。首次编译词库需要一些时间，请等待完成后再输入。输入 `nihao` 即可选择「你好」；按左 Shift 切换中英文。

用户词库和学习记录会保留。语法模型下载使用固定校验值；若上游替换了同名文件导致下载校验失败，需要核实新模型并更新配置中的校验值。

如果从其他方案切换后仍显示旧方案，且「重新部署」无效，可能是旧编译缓存未更新。先退出 Fcitx5，将 `~/.local/share/fcitx5/rime/build` 重命名为一个未使用的备份目录名，再启动 Fcitx5，等待重新编译完成。只移动 `build` 目录，不要删除整个 `rime` 目录或其中的 `*.userdb` 用户词库。

## 参考资料

- [Disko](https://github.com/nix-community/disko)
- [Disko Quickstart](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
- [Disko 示例](https://github.com/nix-community/disko/tree/master/example)
- [Preservation](https://github.com/nix-community/preservation)
