# AGENTS.md

本仓库是用 Nix flake 管理 macOS（nix-darwin）与 NixOS 主机的声明式配置。本文件记录实现约定，供参与修改配置的开发者和自动化代理使用；安装与日常使用说明放在 `docs/`。

## 工作边界

- 修改前先检查相关主机、模块和文档的现状，保留与当前任务无关的本地改动。
- 除非用户明确要求，不要执行 `git add`、提交、推送、创建或修改 PR。
- 不要执行会改变系统状态或历史的命令（`switch`、`update`、`gc`、`install`）；验证只用求值、构建和检查类命令。

## 仓库结构

```
.
├── .envrc
├── .github/
├── docs/
├── flake.nix
├── helpers/
│   └── constants/
├── home/
│   ├── common/
│   ├── darwin/
│   └── nixos/
├── hosts/
│   ├── darwin/
│   └── nixos/
├── Justfile
├── lib/
├── modules/
│   ├── common/          # 跨平台模块（别名、Nix、development'）
│   ├── darwin/          # nix-darwin 模块（core'、programs'）
│   └── nixos/           # NixOS 模块（core'、desktop'、hardware'、services'）
└── outputs/
    ├── aarch64-darwin/
    └── x86_64-linux/
```

## 模块和命名约定

自定义选项使用带撇号的命名空间，避免与 NixOS、nix-darwin 或 Home Manager 的原生选项混淆：

| 命名空间       | 职责                                        |
| -------------- | ------------------------------------------- |
| `accounts'`    | 邮件账户与相关凭据                          |
| `core'`        | 主机与用户元数据、安全功能、darwin 系统偏好 |
| `desktop'`     | 桌面功能与应用开关                          |
| `development'` | 用户工具分组（跨平台开发 CLI、AI 开发工具） |
| `hardware'`    | 硬件支持、引导、磁盘与持久化                |
| `programs'`    | 应用级系统配置（darwin Homebrew）           |
| `services'`    | 主机级系统服务                              |

另有 `preservation'`（Preservation 别名）与 `persist'`（Home Manager 持久化上报）两个机制层选项；`user'`、`hm'` 是 `lib.mkAliasOptionModule` 别名，指向 `users.users.<username>` 和 `home-manager.users.<username>`。

`modules/` 下的目录与上表对齐：NixOS 专属模块按选项前缀归入 `nixos/<namespace>/`（`core/`、`desktop/`、`hardware/`、`services/` 等），跨平台模块放 `common/`（如 `common/development/`），darwin 专属模块放 `darwin/`。新增模块时先按前缀选目录。

## 多设备配置

`helpers/constants/user.nix` 中的 `myvars.username` 是所有主机的唯一用户名来源：

- NixOS 和 nix-darwin 模块使用 `user'` 或 `hm'`；需要字符串时用 `myvars.username`
- Home Manager 直接使用 `myvars.username`
- 不要增加按主机覆盖用户名的第二套配置

主机差异通过主机配置或模块选项表达，不要复制只改用户名、路径或服务参数的模块。

`system.stateVersion` 放在主机配置中；`home.stateVersion` 统一放在 `home/default.nix`。

`nh` 的 flake 路径固定为 `<homeDirectory>/nix-config`：NixOS 在 `modules/nixos/core/nix.nix` 启用，darwin 通过 Home Manager 在 `home/darwin/nh.nix` 启用。

## 持久化规则

`hardware'.persistence.enable` 是 Preservation 的总开关，只在 `modules/nixos/hardware/persistence.nix` 中启用持久化机制。持久化条目跟随所有权：功能开关定义在哪个模块，条目就声明在哪个模块内部。

- `persistence.nix` 只放启动所需、所有设备共用的基线（缓存、无归属模块的凭据等），并汇入 Home Manager 通过 `persist'` 上报的条目
- 纯 Home Manager 工具通过 `home/common/persist.nix` 的 `persist'` 选项上报状态目录和文件（Atuin、Zoxide 等）
- 桌面共用状态（GTK、dconf、密钥环等）跟随生成或消费它们的桌面功能声明；上游模块间接触发的服务（GNOME Keyring、GVfs 等）也有自己的服务模块和开关，持久化按最终服务状态判定
- 服务自己的状态由服务模块声明（VNStat 在 `services/vnstat.nix`，Firefox 在 `desktop/apps/firefox.nix`）
- 功能模块不要重复判断 `hardware'.persistence.enable`；Preservation 自身会按总开关决定是否生成挂载
- 没有启用的服务、桌面功能或应用，不得加入它们专属的持久化目录

推荐的服务模块形态：

```nix
config = lib.mkIf cfg.enable {
  services.vnstat.enable = true;

  preservation'.os.directories = [
    { directory = "/var/lib/vnstat"; user = "vnstatd"; group = "vnstatd"; }
  ];
};
```

## 验证

格式化用 `just fmt` 或 `nix fmt`（nixfmt-rs）；Markdown 用 Prettier，选项在仓库根目录的
`.prettierrc.yaml`（Zed 打开本项目时自动读取，见 `.zed/settings.json`）。按改动范围选择检查：

`just check` 等价于：

```bash
nix fmt . -- --check
prettier --check '**/*.md'
deadnix --fail .
nix flake check path:. --no-build --all-systems
```
