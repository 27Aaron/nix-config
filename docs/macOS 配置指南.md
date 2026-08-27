# macOS 配置指南

本文档介绍如何在全新 macOS 系统上安装 Homebrew 和 Lix，并使用本仓库的 Flake 初始化 nix-darwin。

> [!WARNING]
> **[unstable] `x86_64-darwin` 平台即将停止支持**
>
> 受开发精力和构建资源限制，Nixpkgs 26.05 将是最后一个支持 Intel Mac（`x86_64-darwin`）的版本。随着 [`release: stop building for x86_64-darwin`](https://github.com/NixOS/nixpkgs/pull/493096) 合入，Nixpkgs 26.11 和 unstable 将不再为该平台构建二进制包，也不再支持从源码构建。
>
> Intel Mac 用户应暂时固定在 Nixpkgs 26.05，并尽快迁移到 Apple Silicon 或其他受支持的平台。`allowDeprecatedx86_64Darwin` 只能隐藏弃用警告，不能恢复 unstable 的平台支持，也不建议长期自行维护整套软件包构建。
>
> Homebrew 预计不早于 2026 年 9 月将 Intel Mac 降为 Tier 3，并在 2027 年 9 月后完全停止支持。按照 Nixpkgs 26.05 发布说明采用的时间线，macOS 26 的安全更新预计也将在 2028 年结束。

当前 Darwin 主机配置使用 `aarch64-darwin`，适用于 Apple Silicon Mac，不受上述变更影响。

## 环境准备

### 安装 Homebrew

nix-darwin 的 Homebrew 模块只负责管理软件，不会安装 Homebrew 本身：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装完成后，按照安装程序输出的提示配置 `brew shellenv`，然后确认命令可用：

```bash
brew --version
```

### 安装 Lix

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

重新打开终端，然后确认 Lix 已生效：

```bash
nix --version
```

## 准备配置

克隆仓库并进入仓库根目录：

```bash
git clone https://github.com/27Aaron/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
```

主机目录名必须与 `hostname -s` 的结果一致。仓库默认主机名为 `luna`；如果当前主机名不同，请重命名目录：

```bash
host_name="$(hostname -s)"
mv hosts/darwin/luna "hosts/darwin/$host_name"
```

检查以下配置：

- `vars/default.nix`：用户名、Git 姓名、邮箱、时区
- `hosts/darwin/<主机名>/default.nix`：目标平台
- `modules/darwin/apps/homebrew.nix`：Homebrew 软件清单

> [!CAUTION]
> 当前配置使用 `homebrew.onActivation.cleanup = "zap"`。首次构建会卸载所有未在配置中声明的 Homebrew 软件，并删除 Cask 的关联文件。

如果系统中已经安装了 Homebrew 软件，请先导出清单：

```bash
brew bundle dump --describe --force --file="$HOME/Desktop/Brewfile"
```

根据导出的 Brewfile 更新 `modules/darwin/apps/homebrew.nix` 后再继续。

## 初始化 nix-darwin

在仓库根目录执行：

```bash
sudo nix run nix-darwin/master#darwin-rebuild -- \
  switch --flake "path:.#$(hostname -s)"
```

首次构建会应用 nix-darwin、Home Manager、Homebrew、系统偏好设置和 Touch ID sudo 配置。完成后重新打开终端。

## 后续维护

仓库中的 `justfile` 提供以下命令：

```bash
just switch  # 构建并应用当前主机配置
just check   # 检查格式、未使用声明、NixOS 和 Darwin 配置求值
just update  # 更新 flake.lock
just gc      # 清理 7 天前的旧 generation 及无引用 Store 路径
```

CI 只检查格式、未使用声明和 Nix 语法。更新配置或依赖后，请在本地运行 `just check`，通过后再执行 `just switch`。

新增的 `.nix` 文件会由入口模块自动发现。常用配置目录如下：

- `home/common/`：跨平台 Home Manager 配置
- `home/darwin/`：macOS 专用 Home Manager 配置
- `modules/common/`：跨平台系统模块
- `modules/darwin/`：nix-darwin 系统模块

### 编辑 Karabiner 配置

启用 Homebrew 并安装清单中的 `karabiner-elements` 后，应用配置会直接在 `~/.config/karabiner/karabiner.json` 写入 Nix 生成的键位。这个 JSON 是排版后的普通文件，权限为 `0600`，可以在 Karabiner 设置界面或编辑器中修改，不会链接到 Nix store；Karabiner 会在文件变化时自动重载。

正常 `just switch` 会保留手动编辑。修改 Nix 中的键位规则后，再次应用时会把当前 JSON 改名为同目录的 `karabiner.json.hm-bak`（单份滚动备份，下次覆盖），然后写入新规则；手动编辑不会自动写回 Git。该行为通过旁边的 `.nix-generated-karabiner.json` 记录文件实现，请保留它，并把整个 Karabiner 配置目录纳入个人备份。

## 参考资料

- [Homebrew 安装文档](https://docs.brew.sh/Installation)
- [Homebrew 支持等级](https://docs.brew.sh/Support-Tiers)
- [Lix 安装文档](https://lix.systems/install/)
- [Nixpkgs 26.05 发布说明](https://nixos.org/manual/nixpkgs/unstable/release-notes#x86_64-darwin-26.05)
- [Nixpkgs 停止构建 `x86_64-darwin`](https://github.com/NixOS/nixpkgs/pull/493096)
- [nix-darwin 使用说明](https://github.com/nix-darwin/nix-darwin)
- [nix-darwin 配置选项](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager 配置选项](https://home-manager-options.extranix.com/)
