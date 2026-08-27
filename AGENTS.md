# AGENTS.md

本文件记录本仓库的实现约定，供参与修改配置的开发者和自动化代理使用。安装和日常使用说明请放在 `docs/`，不要把内部模块设计写进安装指南。

## 工作边界

- 修改前先检查相关主机、模块和文档的现状，保留与当前任务无关的本地改动。
- 除非用户明确要求，不要执行 `git add`、提交、推送、创建或修改 PR。
- 配置改动完成后，至少运行格式检查、`deadnix` 和 Nix 语法检查。

## 项目结构

主机入口位于 `hosts/`：

- `hosts/nixos/<host>/`：NixOS 主机配置与硬件配置
- `hosts/darwin/<host>/`：nix-darwin 主机配置
- `hosts/default.nix`：构造各平台主机，并将 Home Manager 接入对应用户

系统模块位于 `modules/`：

- `modules/common/`：跨平台系统基础配置
- `modules/nixos/system/`：NixOS 基础系统、启动、硬件和安全配置
- `modules/nixos/services/`：主机级服务，例如网络、SSH、监控和打印
- `modules/nixos/apps/`：应用级系统服务，例如 PostgreSQL
- `modules/nixos/storage/`：Disko 和 Preservation 配置
- `modules/nixos/desktop/`：桌面环境配置
- `modules/darwin/system/`、`modules/darwin/apps/`、`modules/darwin/security/`：nix-darwin 配置

Home Manager 配置位于 `home/`：

- `home/common/`：macOS 和 NixOS 共用的用户配置
- `home/nixos/`、`home/darwin/`：平台专属用户配置
- `home/darwin/apps/`：平台专属的用户应用配置

`modules/default.nix` 和 `home/default.nix` 会自动发现对应目录中的 Nix 文件。新增模块应放入正确的职责目录，不要在主机文件中堆积可复用逻辑。

## 模块和命名约定

自定义选项使用带撇号的命名空间，避免和 NixOS、nix-darwin 或 Home Manager 的原生选项混淆：

- `core'`：主机和主用户元数据
- `services'`：主机级系统服务
- `desktop'`：桌面功能
- `hardware'`：可选硬件支持
- `security'`：安全功能
- `storage'`：磁盘和持久化功能
- `user'`：当前主用户的 NixOS 用户选项快捷入口
- `hm'`：当前主用户的 Home Manager 选项快捷入口

可选模块通常定义自己的 `enable` 选项，并用该选项包住全部配置：

```nix
options.services'.example.enable = lib.mkEnableOption "Example service";

config = lib.mkIf cfg.enable {
  # module-owned configuration
};
```

模块的自定义 `enable` 是功能边界。若它负责启用底层服务，底层 `enable` 应直接设置为 `true`，避免自定义开关和原生开关产生分叉。`lib.mkDefault` 只用于确实需要让主机覆盖的默认值。

一个模块文件只承载一个功能或服务。被多个桌面依赖的底层能力（如 Greetd、Bluetooth、UPower）拆成独立模块并持有自己的持久化条目，需要它们的模块或主机显式开启对应开关；持久化跟随最终服务状态判定，无论由哪个开关打开。

PostgreSQL 文件按仓库约定放在 `modules/nixos/apps/`，但它是系统服务，所以选项仍使用 `services'.postgresql`。

Karabiner 配置位于 `home/darwin/apps/karabiner.nix`，不设置独立的启用开关。它读取 nix-darwin 的 `apps'.homebrew` 配置，只有 Homebrew 启用且 `casks` 包含 `karabiner-elements` 时才生成配置文件。不要在主机文件中重复添加 Karabiner 开关；Homebrew 的声明列表是唯一来源。

桌面应用（Firefox、Kitty 等）的启用开关统一放在 `desktop'.apps.<app>.enable`，由 `modules/nixos/desktop/` 下的应用模块定义，模块内部通过 `hm'` 设置 Home Manager 的原生选项。不要为单个用户应用在 Home Manager 里新建自定义命名空间。

## 多设备配置

`vars/default.nix` 中的 `myvars.username` 是所有主机的唯一用户名来源。需要引用当前用户时：

- NixOS 和 nix-darwin 模块使用 `user'` 或 `hm'`；需要字符串时直接使用 `myvars.username`
- Home Manager 直接使用 `myvars.username`
- 不要在模块中增加按主机覆盖用户名的第二套配置

主机差异应通过主机配置或模块选项表达，不要复制一份只改用户名、路径或服务参数的模块。

`system.stateVersion` 放在具体主机配置中；Home Manager 的 `home.stateVersion` 统一放在 `home/default.nix`。

## 持久化规则

`storage'.persistence.enable` 是 Preservation 的总开关，只在 `modules/nixos/storage/persistence.nix` 中负责启用持久化机制。

持久化条目跟随所有权：功能开关定义在哪个模块，对应条目就声明在哪个模块内部。

- `persistence.nix` 只放机器启动所需、系统基础和所有设备共用的用户基线（缓存、无归属模块的凭据等），并把 Home Manager 通过 `persist'` 上报的条目汇入 preservation 选项
- 纯 Home Manager 工具无法直接写 NixOS 选项，通过 `home/common/persist.nix` 定义的 `persist'` 选项上报自己的状态目录和文件（例如 Atuin、Zoxide、AI CLI）
- 桌面共用状态（GTK、dconf、密钥环等）跟随生成或消费它们的桌面功能声明，例如 GTK/dconf 放在 `desktop/themes.nix`；由上游模块间接触发的系统服务（如 PipeWire、AccountsService）也拥有自己的服务模块和 `services'.<name>.enable` 开关，持久化按最终服务状态判定
- 服务自己的状态由服务模块声明，例如 VNStat 放在 `services/vnstat.nix`；桌面功能和应用由 `desktop/` 下定义各自开关的模块声明，例如 Firefox 放在 `desktop/firefox.nix`
- 功能模块不要重复判断 `storage'.persistence.enable`；Preservation 自身会根据总开关决定是否生成实际挂载
- 没有启用的服务、桌面功能或应用，不得加入它们专属的持久化目录

推荐的服务模块形态：

```nix
config = lib.mkIf cfg.enable {
  services.vnstat.enable = true;

  preservation'.os.directories = [
    {
      directory = "/var/lib/vnstat";
      user = "vnstatd";
      group = "vnstatd";
    }
  ];
};
```

## 文档边界

`docs/*安装指南.md` 只描述用户完成安装、初始化和升级所需的步骤。模块目录、命名空间、开关职责、持久化策略等内部设计写在本文件，不要重复放进安装指南。

## 验证

常规检查：

```bash
alejandra .
deadnix --fail .

for file in $(rg --files -g '*.nix'); do
  nix-instantiate --parse "$file" >/dev/null || exit 1
done
```

完整配置检查：

```bash
nix flake check --no-build
```

如果工作区包含尚未纳入 Git 的新文件，应在包含完整工作区内容的临时非 Git 副本中运行 flake 检查，避免 Nix 的 Git flake 读取器遗漏这些文件。
