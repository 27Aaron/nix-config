# macOS 配置指南

本文档介绍如何在全新的 macOS 上安装 Homebrew 和 Lix，并使用本仓库的 Flake 初始化 nix-darwin。

> [!WARNING]
> **Intel Mac（`x86_64-darwin`）即将失去上游支持**
>
> Nixpkgs 26.05 是最后一个支持 Intel Mac 的版本；26.11 与 unstable 不再为该平台构建二进制包（[PR #493096](https://github.com/NixOS/nixpkgs/pull/493096)）。Intel Mac 用户应固定在 26.05 并尽快迁移到 Apple Silicon。

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
git clone https://github.com/27Aaron/nix-config.git ~/nix-config
cd ~/nix-config
```

主机目录名必须与 `hostname -s` 的结果一致。仓库默认主机为 `luna`，如果当前主机名不同，请重命名目录与输出声明文件：

```bash
host_name="$(hostname -s)"
mv hosts/darwin/luna "hosts/darwin/$host_name"
mv outputs/aarch64-darwin/src/luna.nix "outputs/aarch64-darwin/src/$host_name.nix"
mv outputs/aarch64-darwin/tests/luna.nix "outputs/aarch64-darwin/tests/$host_name.nix"
```

再把两个输出文件内容里的 `luna` 改为新主机名（`src/` 的声明与 `tests/` 的断言引用），否则 `just check` 会因找不到该主机而失败。

检查以下配置：

- `helpers/constants/user.nix`：用户名、Git 姓名、邮箱、时区
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

新增的 `.nix` 文件会被自动导入，无需手动登记。常用的配置目录：

- `home/common/`：跨平台 Home Manager 配置
- `home/darwin/`：macOS 专用 Home Manager 配置
- `modules/common/`：跨平台系统模块
- `modules/darwin/`：nix-darwin 系统模块

## 参考资料

- [Homebrew 安装文档](https://docs.brew.sh/Installation)
- [Homebrew 支持等级](https://docs.brew.sh/Support-Tiers)
- [Lix 安装文档](https://lix.systems/install/)
- [Nixpkgs 26.05 发布说明](https://nixos.org/manual/nixpkgs/unstable/release-notes#x86_64-darwin-26.05)
- [Nixpkgs 停止构建 `x86_64-darwin`](https://github.com/NixOS/nixpkgs/pull/493096)
- [nix-darwin 使用说明](https://github.com/nix-darwin/nix-darwin)
- [nix-darwin 配置选项](https://nix-darwin.github.io/nix-darwin/manual/)
- [Home Manager 配置选项](https://home-manager-options.extranix.com/)
