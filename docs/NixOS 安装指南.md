# NixOS 安装指南

本文档介绍如何从 NixOS 安装介质启动，使用独立的 Disko 配置创建文件系统，并通过本仓库的 Flake 安装 `elaina`。

> [!CAUTION]
> Disko 会清空目标磁盘上的所有分区和数据。执行前请备份数据，并再次确认目标磁盘。

## Disko 配置

将以下内容保存为 `disko.nix`。这是一份可以独立使用的安装配置，同时也作为当前磁盘布局的备份。

```nix
{...}: {
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "mode=755"
        "nodev"
        "nosuid"
        "relatime"
        "size=4G"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-CT1000P3PSSD8_24364AD5D8E0";

      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [
                "-n"
                "BOOT"
              ];
              mountOptions = ["umask=0077"];
            };
          };

          luks = {
            priority = 2;
            size = "100%";
            type = "8309";
            content = {
              type = "luks";
              name = "crypted";
              askPassword = true;
              initrdUnlock = true;
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
                crypttabExtraOpts = [
                  "same-cpu-crypt"
                  "submit-from-crypt-cpus"
                  "token-timeout=10"
                ];
              };
              extraFormatArgs = [
                "--type"
                "luks2"
                "--pbkdf"
                "argon2id"
              ];

              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "--csum"
                  "xxhash64"
                  "--label"
                  "NixOS"
                ];
                mountpoint = "/btr_pool";
                mountOptions = [
                  "noatime"
                  "subvolid=5"
                ];

                subvolumes = {
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd:1"
                      "discard=async"
                      "noatime"
                    ];
                  };

                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [
                      "compress=zstd:1"
                      "discard=async"
                      "noatime"
                    ];
                  };

                  "@snapshots" = {
                    mountpoint = "/snapshots";
                    mountOptions = [
                      "compress=zstd:1"
                      "discard=async"
                      "noatime"
                    ];
                  };

                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "32769M";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
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

Disko 会要求确认清空磁盘，并交互式询问 LUKS 密码。完成后确认文件系统已经挂载到 `/mnt`：

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

检查 `/mnt/etc/nixos/hardware-configuration.nix`，将仍然需要的硬件探测结果合并到 `hosts/nixos/elaina/hardware.nix`，不要覆盖已有的 Disko 和引导配置。

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

启动时输入 LUKS 密码，然后使用 `vars/default.nix` 中配置的账户登录。

> [!IMPORTANT]
> 根文件系统使用 tmpfs，系统设计为将需要保留的数据存储到 `/persistent`；未持久化的数据会在重启后消失。

## 参考资料

- [Disko](https://github.com/nix-community/disko)
- [Disko Quickstart](https://github.com/nix-community/disko/blob/master/docs/quickstart.md)
- [Disko 示例](https://github.com/nix-community/disko/tree/master/example)
- [Preservation](https://github.com/nix-community/preservation)
