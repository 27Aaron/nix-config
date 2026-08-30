# macOS 配置指南

本文档介绍如何在全新的 macOS 上安装 Homebrew 和 Lix，并使用本仓库的 Flake 初始化 nix-darwin。

> [!WARNING]
> **Intel Mac（`x86_64-darwin`）即将失去上游支持**
>
> 受上游开发精力和构建资源限制，Nixpkgs 26.05 将是最后一个支持 Intel Mac（`x86_64-darwin`）的版本。随着 [`release: stop building for x86_64-darwin`](https://github.com/NixOS/nixpkgs/pull/493096) 合入，Nixpkgs 26.11 和 unstable 将不再为该平台构建二进制包，也不再支持从源码构建。
>
> Intel Mac 用户应暂时固定在 Nixpkgs 26.05，并尽快迁移到 Apple Silicon 或其他受支持的平台。`allowDeprecatedx86_64Darwin` 只能隐藏弃用警告，无法恢复 unstable 的平台支持，长期自行维护整套软件包构建也不可取。
>
> Homebrew 预计不早于 2026 年 9 月将 Intel Mac 降为 Tier 3，并在 2027 年 9 月后完全停止支持。按照 Nixpkgs 26.05 发布说明采用的时间线，macOS 26 的安全更新预计也将在 2028 年结束。

本仓库的 Darwin 主机为 `aarch64-darwin`（Apple Silicon），不受上述变更影响。

## 环境准备

### 安装 Homebrew

nix-darwin 的 Homebrew 模块只负责管理软件清单，不会安装 Homebrew 本身，需要先手动安装：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装完成后，按安装程序输出的提示把 `brew shellenv` 写入 shell 配置，然后确认命令可用：

```bash
brew --version
```

### 安装 Lix

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

重新打开终端，确认 Lix 已生效：

```bash
nix --version
```

## 准备配置

克隆仓库并进入仓库根目录：

```bash
git clone https://github.com/27Aaron/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
```

主机目录名必须与 `hostname -s` 的结果一致。仓库默认主机为 `luna`，如果当前主机名不同，请重命名目录：

```bash
host_name="$(hostname -s)"
mv hosts/darwin/luna "hosts/darwin/$host_name"
```

检查以下配置：

- `vars/default.nix`：用户名、Git 姓名、邮箱、时区
- `hosts/darwin/<主机名>/default.nix`：目标平台
- `modules/darwin/apps/homebrew.nix`：Homebrew 软件清单

> [!CAUTION]
> 当前配置启用了 `homebrew.onActivation.cleanup = "zap"`：首次激活会卸载所有未在清单中声明的 Homebrew 软件，并删除 Cask 的关联文件。

如果系统中已经装过 Homebrew 软件，先导出清单：

```bash
brew bundle dump --describe --force --file="$HOME/Desktop/Brewfile"
```

对照导出的 Brewfile 补全 `modules/darwin/apps/homebrew.nix` 后再继续。

## 初始化 nix-darwin

在仓库根目录执行：

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- \
  switch --flake "path:.#$(hostname -s)"
```

首次执行会依次应用 nix-darwin、Home Manager、Homebrew、系统偏好设置和 Touch ID sudo 配置。完成后重新打开终端，之后的日常维护直接使用 `just switch`。

## 后续维护

仓库的 `Justfile` 提供以下命令：

```bash
just switch  # 构建并应用当前主机配置
just check   # 检查格式、未使用声明、NixOS 和 Darwin 配置求值
just update  # 更新 flake.lock
just gc      # 清理 7 天前的旧 generation 及无引用 Store 路径
```

仓库不设远程 CI。修改配置或依赖后，先在本地运行 `just check`，通过后再执行 `just switch`。

新增的 `.nix` 文件会被自动导入，无需手动登记。常用的配置目录：

- `home/common/`：跨平台 Home Manager 配置
- `home/darwin/`：macOS 专用 Home Manager 配置
- `modules/common/`：跨平台系统模块
- `modules/darwin/`：nix-darwin 系统模块

### 编辑 Karabiner 配置

Homebrew 启用且清单中包含 `karabiner-elements` 时，每次激活都会在 `~/.config/karabiner/karabiner.json` 写入由 Nix 生成的键位配置。这是一个排版过的普通 JSON 文件（权限 `0600`），不链接到 Nix store，可以在编辑器或 Karabiner 设置界面中直接修改；Karabiner 检测到文件变化后会自动重载。

每次 `just switch` 会先把现有 JSON 备份为同目录的 `karabiner.json.hm-bak`（覆盖上一份备份），再写入 Nix 配置；更早的时间戳备份会被清理，始终只保留一份。备份是独立文件，不依赖 Nix store。

手动编辑随时可行，但下次 `just switch` 会用 Nix 配置覆盖这些修改，被覆盖前的内容会留在备份里。需要长期保留的键位，请修改仓库中的 Nix 配置。如果旧的 Karabiner 配置目录还是软链接，先把内容复制出来、换成普通目录，再执行 `just switch`。

## 参考资料

- [Homebrew 安装文档](https://docs.brew.sh/Installation)
- [Homebrew 支持等级](https://docs.brew.sh/Support-Tiers)
- [Lix 安装文档](https://lix.systems/install/)
- [Nixpkgs 26.05 发布说明](https://nixos.org/manual/nixpkgs/unstable/release-notes#x86_64-darwin-26.05)
- [Nixpkgs 停止构建 `x86_64-darwin`](https://github.com/NixOS/nixpkgs/pull/493096)
- [nix-darwin 使用说明](https://github.com/nix-darwin/nix-darwin)
- [nix-darwin 配置选项](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager 配置选项](https://home-manager-options.extranix.com/)
