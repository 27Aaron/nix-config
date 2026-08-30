# AGENTS.md

本文件记录本仓库的实现约定，供参与修改配置的开发者和自动化代理使用。安装和日常使用说明放在 `docs/`，不要把内部模块设计写进安装指南。

## 工作边界

- 修改前先检查相关主机、模块和文档的现状，保留与当前任务无关的本地改动。
- 除非用户明确要求，不要执行 `git add`、提交、推送、创建或修改 PR。
- 配置改动完成后，至少运行格式检查和 `deadnix`（见「验证」）。

## 仓库结构

```
flake.nix             Flake 入口：导出所有主机、formatter 和模块
vars/default.nix      全局变量：用户名、姓名、邮箱、时区、密码哈希、SSH 公钥
hosts/
  darwin/<host>/      nix-darwin 主机（default.nix）
  nixos/<host>/       NixOS 主机（default.nix + hardware.nix，可含 network.nix 等附加文件）
modules/
  common/             跨平台系统模块
  nixos/system/       基础系统、引导、硬件和安全
  nixos/services/     主机级服务
  nixos/apps/         应用级系统服务（如 PostgreSQL）
  nixos/storage/      Disko 和 Preservation
  nixos/desktop/      桌面环境
  darwin/system/      nix-darwin 系统配置
  darwin/apps/        nix-darwin 应用配置（Homebrew）
  darwin/security/    nix-darwin 安全配置
home/
  common/             跨平台 Home Manager 配置
  nixos/  darwin/     平台专属用户配置
docs/                 安装指南（面向使用者，不含内部设计）
.github/              GitHub PR 自动化（label、dependabot 等，不含 CI 检查）
Justfile              switch / check / update / gc / fmt 等常用命令
```

装配与自动发现：

- `hosts/default.nix` 把 `hosts/<平台>/<主机名>/default.nix` 构造成一台主机，目录名即 flake 里的主机名。
- 每台主机注入同一组 `specialArgs`：`inputs`、`myvars`、`hostName`、`platformName`；Home Manager 通过 `extraSpecialArgs` 收到同一组，并以 `backupFileExtension = "hm-bak"` 接入主用户。模块和 Home Manager 文件可以直接取用这些参数。
- `modules/default.nix` 递归扫描 `modules/common/` 和当前平台目录：含 `default.nix` 的目录作为单个模块整体导入，否则继续下钻；普通 `.nix` 文件直接导入。新增模块放入正确的职责目录即可，无需登记。
- `home/default.nix` 递归导入 `home/common/` 和平台目录下的所有 `.nix` 文件。
- NixOS 主机的 `default.nix` 按 `imports`、`services'`、`desktop'`、安全配置（`security` / `security'`）、`tools'`、`system.stateVersion` 的顺序组织，分组内按名称排序。
- NixOS 主机的 `hardware.nix` 持有硬件探测结果、`hardware'` 硬件支持开关、内核、引导与主机级存储配置：`storage'.disko` 磁盘参数（`device`、`tmpfsSize`、`espSize`、`swapSize`、`luks.enable`）和 `storage'.persistence.enable`。功能所属的持久化文件和目录清单仍由各自模块声明。

## 模块和命名约定

自定义选项使用带撇号的命名空间，避免和 NixOS、nix-darwin 或 Home Manager 的原生选项混淆：

| 命名空间 | 职责 | 定义位置 |
| --- | --- | --- |
| `core'` | 主机与主用户元数据：hostName、timeZone、hashedPassword、sshAuthorizedKeys | `modules/*/system/core.nix` |
| `system'` | 系统级杂项（darwin 系统偏好 `system'.defaults`） | `modules/darwin/system/` |
| `apps'` | 应用级系统配置（darwin Homebrew `apps'.homebrew`） | `modules/darwin/apps/` |
| `tools'` | 跨平台用户 CLI 工具分组（`tools'.dev`、`tools'.coding-agents`） | `modules/common/` |
| `services'` | 主机级系统服务（含 PostgreSQL） | `modules/nixos/services/`、`modules/nixos/apps/` |
| `desktop'` | 桌面功能与应用开关 | `modules/nixos/desktop/` |
| `hardware'` | 可选硬件支持 | `modules/nixos/system/` |
| `security'` | 安全功能（firewall、touch-id） | `modules/nixos/system/`、`modules/darwin/security/` |
| `storage'` | 磁盘与持久化（disko、persistence） | `modules/nixos/storage/` |
| `preservation'` | Preservation 选项别名，`os` / `user` 对应 `/persistent` 下的系统与用户条目 | `modules/nixos/storage/persistence.nix` |
| `persist'` | 纯 Home Manager 工具上报的持久化条目 | `home/common/persist.nix` |

`user'` 和 `hm'` 不是独立声明的选项，而是 `core'` 模块里用 `lib.mkAliasOptionModule` 创建的别名，分别指向 `users.users.<username>` 和 `home-manager.users.<username>`，供模块书写用户和 Home Manager 配置时使用。

可选模块通常定义自己的 `enable` 选项，并用该选项包住全部配置：

```nix
options.services'.example = {
  enable = lib.mkEnableOption "Example service";
};

config = lib.mkIf cfg.enable {
  # module-owned configuration
};
```

模块的自定义 `enable` 是功能边界。若它负责启用底层服务，底层 `enable` 应直接设置为 `true`，避免自定义开关和原生开关产生分叉。`lib.mkDefault` 只用于确实需要让主机覆盖的默认值。

一个模块文件只承载一个功能或服务。被多个桌面依赖的底层能力（如 Greetd、Bluetooth、UPower）拆成独立模块并持有自己的持久化条目，需要它们的模块或主机显式开启对应开关；持久化跟随最终服务状态判定，无论由哪个开关打开。

PostgreSQL 文件按仓库约定放在 `modules/nixos/apps/`，但它是系统服务，所以选项仍使用 `services'.postgresql`。

Karabiner 配置位于 `home/darwin/apps/karabiner.nix`，不设独立开关：Homebrew 启用且 `casks` 包含 `karabiner-elements` 时才生效，Homebrew 声明列表是唯一来源。每次激活先把已有 JSON 备份为 `karabiner.json.hm-bak`（覆盖上一份），再把 Nix 生成的内容写到 `${xdg.configHome}/karabiner/karabiner.json`。配置和新备份均为 `0600` 的普通文件，可直接编辑；手改会在下次激活时被 Nix 配置替换，并留在备份中。

激活在 Home Manager 的 `writeBoundary` 之后、`linkGeneration` 之前执行，`dry-run` 不写文件。不再记录生成内容或自动迁移目录链接；旧目录链接需要先手动改成普通目录。写入新备份后清理早期的时间戳备份，完成后删除旧的规则记录文件，保持单份备份。JSON 链接需复制为独立备份，不修改已有备份链接指向的数据。

桌面应用（Firefox、Kitty 等）的启用开关统一放在 `desktop'.apps.<app>.enable`，由 `modules/nixos/desktop/` 下的应用模块定义，模块内部通过 `hm'` 设置 Home Manager 的原生选项。不要为单个用户应用在 Home Manager 里新建自定义命名空间。

跨平台的开发 CLI 工具集（gh、lazygit、uv、direnv、Nix 工具链）由 `tools'.dev.enable` 控制，安装、集成和持久化配置收敛在 `modules/common/tools.nix`；Shell 专属的 `uv` / `uvx` 补全分别放在 `home/common/fish.nix` 和 `home/common/zsh.nix`，并按命令是否存在加载。Claude Code 和 Codex 由 `tools'.coding-agents.enable` 控制，配置收敛在 `modules/common/coding-agents.nix`。其他带开关的内容不放入 `home/common/` 基线。`just` 属于所有主机共用的基线工具，放在 `home/common/misc.nix`。XDG 用户目录是桌面能力，由 `desktop'.xdg-user-dirs.enable` 控制，不放进 `home/nixos/` 基线。

## 多设备配置

`vars/default.nix` 中的 `myvars.username` 是所有主机的唯一用户名来源。需要引用当前用户时：

- NixOS 和 nix-darwin 模块使用 `user'` 或 `hm'`；需要字符串时直接使用 `myvars.username`
- Home Manager 直接使用 `myvars.username`
- 不要在模块中增加按主机覆盖用户名的第二套配置

主机差异应通过主机配置或模块选项表达，不要复制一份只改用户名、路径或服务参数的模块。

`system.stateVersion` 放在具体主机配置中；Home Manager 的 `home.stateVersion` 统一放在 `home/default.nix`。

NixOS 上 `nh` 的 flake 路径固定为 `/home/<username>/nix-config`（`modules/nixos/system/nix.nix`），安装指南也按此路径克隆仓库。

## 持久化规则

`storage'.persistence.enable` 是 Preservation 的总开关，只在 `modules/nixos/storage/persistence.nix` 中负责启用持久化机制。

持久化条目跟随所有权：功能开关定义在哪个模块，对应条目就声明在哪个模块内部。

- `persistence.nix` 只放机器启动所需、系统基础和所有设备共用的用户基线（缓存、无归属模块的凭据等），并把 Home Manager 通过 `persist'` 上报的条目汇入 preservation 选项
- 纯 Home Manager 工具无法直接写 NixOS 选项，通过 `home/common/persist.nix` 定义的 `persist'` 选项上报自己的状态目录和文件（例如 Atuin、Zoxide）
- 桌面共用状态（GTK、dconf、密钥环等）跟随生成或消费它们的桌面功能声明，例如 GTK/dconf 放在 `desktop/themes.nix`；由上游模块间接触发的系统服务（如 GNOME Keyring 会被 niri 开启、power-profiles-daemon 会被 DMS 开启）也拥有自己的服务模块和 `services'.<name>.enable` 开关，持久化按最终服务状态判定
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

`docs/*安装指南.md`、`docs/*配置指南.md` 只描述用户完成安装、初始化和升级所需的步骤，以及日常使用的注意事项。模块目录、命名空间、开关职责、持久化策略等内部设计写在本文件，不要重复放进指南。

## 验证

常规检查：

```bash
alejandra .
deadnix --fail .
```

完整检查（含所有主机求值）：

```bash
nix flake check --no-build
```

如果工作区包含尚未纳入 Git 的新文件，应在包含完整工作区内容的临时非 Git 副本中运行 flake 检查，避免 Nix 的 Git flake 读取器遗漏这些文件。

检查全部在本地运行：`just check` 包含格式检查、未使用声明和所有主机求值；格式化用 `just fmt` 或 `nix fmt`。仓库不设远程 CI 检查，GitHub 上仅保留 issue/PR 的标签和依赖更新自动化。
