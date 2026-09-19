# AGENTS.md

本文件记录本仓库的实现约定，供参与修改配置的开发者和自动化代理使用。安装和日常使用说明放在 `docs/`，不要把内部模块设计写进安装指南。

## 工作边界

- 修改前先检查相关主机、模块和文档的现状，保留与当前任务无关的本地改动。
- 除非用户明确要求，不要执行 `git add`、提交、推送、创建或修改 PR。
- 配置改动完成后，至少运行格式检查和 `deadnix`（见「验证」）。

## 仓库结构

```
flake.nix             Flake 入口：导出所有主机、devShells、formatter 和 checks
helpers/              共享库：作为 specialArgs 注入所有主机与 Home Manager
  default.nix         汇聚入口：展开 constants/ 下的注册表
  constants/          共享常量注册表
    btrfs.nix         磁盘布局：Btrfs 池、持久化与快照路径
    fonts.nix         字体族名：等宽与 emoji
    nix.nix           二进制缓存：substituters 与 trustedPublicKeys
    path.nix          路径：主目录与仓库克隆路径（按平台计算）
    ports.nix         服务端口：port 数字与 portStr 字符串
    user.nix          用户元数据：用户名、姓名、邮箱、时区、密码哈希、SSH 公钥
lib/
  default.nix         通用函数：scanPaths 递归收集模块路径
  platforms.nix       平台差异表：构建器、Home Manager 模块、模块目录
  mkHost.nix          主机构建器：specialArgs、Home Manager 接线与主机目录组装
  checks.nix          flake checks：格式、deadnix、darwin 求值与主机断言
  eval-tests.nix      主机关键值断言：冻结主机角色与关键配置
hosts/
  default.nix         主机发现：目录名即 flake 里的主机名
  darwin/<host>/      nix-darwin 主机（default.nix）
  nixos/<host>/       NixOS 主机（default.nix + hardware.nix，可含 network.nix 等附加文件）
modules/
  default.nix         模块装配：按平台递归导入 common/ 与平台目录
  common/             跨平台系统模块
  nixos/system/       系统基线：core、i18n、shell、nix 设置
  nixos/boot/         引导：GRUB、systemd-boot、initrd SSH
  nixos/hardware/     可选硬件支持
  nixos/security/     安全功能（firewall）
  nixos/services/     与桌面无关的系统服务（远程访问、网络、内存、打印）
  nixos/apps/         应用级系统服务（如 PostgreSQL）与用户工具集（如 AI 开发工具）
  nixos/desktop/      桌面：session/ 会话栈、apps/ 应用、environment/ 外观与输入
  nixos/storage/      Disko、Preservation 与存储维护（btrbk、scrub、smartd）
  darwin/system/      nix-darwin 系统配置
  darwin/apps/        nix-darwin 应用配置（Homebrew）
  darwin/security/    nix-darwin 安全配置
home/
  default.nix         用户配置装配：递归导入 common/ 与平台目录
  common/             跨平台 Home Manager 配置
  nixos/  darwin/     平台专属用户配置
docs/                 安装指南（面向使用者，不含内部设计）
.github/              GitHub PR 自动化（label、dependabot 等，不含 CI 检查）
Justfile              switch / check / update / gc / fmt 等常用命令
.envrc                direnv：进入仓库时加载 devShell（use flake）
```

装配与自动发现：

- `hosts/default.nix` 把 `hosts/<平台>/<主机名>/default.nix` 构造成一台主机，目录名即 flake 里的主机名；构建器在 `lib/mkHost.nix`，平台差异集中在 `lib/platforms.nix`。
- 每台主机注入同一组 `specialArgs`：`inputs`、`myvars`、`hostName`、`platformName`、`helpers`；Home Manager 通过 `extraSpecialArgs` 收到同一组，并以 `backupFileExtension = "hm-bak"` 接入主用户。模块和 Home Manager 文件可以直接取用这些参数。
- `helpers` 由 `lib/mkHost.nix` 从 `helpers/default.nix` 求值注入（求值时带上 `platformName`，`path.nix` 等按平台计算的常量由此而来）；`myvars` 就是其中的 `user` 注册表。模块通过 `helpers.port.openssh`、`helpers.portStr.openssh`、`helpers.nix.substituters`、`helpers.path.nixConfig`、`helpers.btrfs.pool`、`helpers.fonts.monospace` 等路径引用共享常量。
- `modules/default.nix` 与 `home/default.nix` 共用 `lib/default.nix` 的 `scanPaths` 递归收集：含 `default.nix` 的目录作为单个模块整体导入，否则继续下钻；普通 `.nix` 文件直接导入。前者收集 `modules/common/` 与当前平台模块目录，后者收集 `home/common/` 与当前平台 Home Manager 目录。新增模块放入正确的职责目录即可，无需登记。
- NixOS 主机的 `default.nix` 按 `imports`、`services'`、`desktop'`、安全配置（`security` / `security'`）、`tools'`、`system.stateVersion` 的顺序组织。
- NixOS 主机的 `hardware.nix` 持有硬件探测结果、`hardware'` 硬件支持开关、内核、引导与主机级存储配置：`storage'.disko` 磁盘参数（`device`、`tmpfsSize`、`espSize`、`swapSize`、`luks.enable`、`bios.enable`）和 `storage'.persistence.enable`。功能所属的持久化文件和目录清单仍由各自模块声明。
- Flake inputs 中的 `secrets`（私有仓库 `27Aaron/nix-secrets`，sops 密钥库）和 `nur-aaron`（个人 NUR 包）为服务器主机预留；更新 lock 文件需要能访问前者的 SSH。

## 模块和命名约定

自定义选项使用带撇号的命名空间，避免和 NixOS、nix-darwin 或 Home Manager 的原生选项混淆：

| 命名空间 | 职责 | 定义位置 |
| --- | --- | --- |
| `core'` | 主机与主用户元数据：hostName、timeZone、hashedPassword、sshAuthorizedKeys | `modules/*/system/core.nix` |
| `boot'` | 引导：GRUB、systemd-boot、initrd SSH | `modules/nixos/boot/` |
| `system'` | 系统级杂项（darwin 系统偏好 `system'.defaults`） | `modules/darwin/system/` |
| `apps'` | 应用级系统配置（darwin Homebrew `apps'.homebrew`） | `modules/darwin/apps/` |
| `tools'` | 用户工具分组：跨平台开发 CLI（`tools'.dev`）、NixOS AI 开发工具（`tools'.ai`） | `modules/common/`、`modules/nixos/apps/` |
| `services'` | 主机级系统服务（含 PostgreSQL） | `modules/nixos/services/`、`modules/nixos/apps/`、`modules/nixos/desktop/session/`、`modules/nixos/storage/` |
| `desktop'` | 桌面功能与应用开关 | `modules/nixos/desktop/` |
| `hardware'` | 可选硬件支持 | `modules/nixos/hardware/` |
| `security'` | 安全功能（firewall、kernel-hardening、arp-filter、touch-id） | `modules/nixos/security/`、`modules/darwin/security/` |
| `storage'` | 磁盘与持久化（disko、persistence） | `modules/nixos/storage/` |
| `preservation'` | Preservation 选项别名，`os` / `user` 对应 `/persistent` 下的系统与用户条目 | `modules/nixos/storage/persistence.nix` |
| `persist'` | 纯 Home Manager 工具上报的持久化条目 | `home/common/persist.nix` |

`user'` 和 `hm'` 不是独立声明的选项，而是 `modules/common/aliases.nix` 里用 `lib.mkAliasOptionModule` 创建的别名，分别指向 `users.users.<username>` 和 `home-manager.users.<username>`，供模块书写用户和 Home Manager 配置时使用。

可选模块通常定义自己的 `enable` 选项，并用该选项包住全部配置：

```nix
options.services'.example = {
  enable = lib.mkEnableOption "Example service";
};

config = lib.mkIf cfg.enable {
  # module-owned configuration
};
```

选项声明风格：模块入口的总开关用 `lib.mkEnableOption`；其余选项（含子命名空间的布尔开关，如 `storage'.disko.luks.enable`）统一写成显式的 `lib.mkOption`，带 `type`、`default` 和 `description`。

模块的自定义 `enable` 是功能边界。若它负责启用底层服务，底层 `enable` 应直接设置为 `true`，避免自定义开关和原生开关产生分叉。`lib.mkDefault` 只用于确实需要让主机覆盖的默认值。

一个模块文件只承载一个功能或服务。被多个桌面依赖的底层能力（如 Greetd、Bluetooth、UPower）拆成独立模块并持有自己的持久化条目，需要它们的模块或主机显式开启对应开关；持久化跟随最终服务状态判定，无论由哪个开关打开。

PostgreSQL 文件按仓库约定放在 `modules/nixos/apps/`，但它是系统服务，所以选项仍使用 `services'.postgresql`。

NixOS 模块目录按职责域组织：`system/` 只放无独立开关的系统基线；引导、硬件、安全分别归 `boot/`、`hardware/`、`security/`；桌面的会话栈与底层会话服务归 `desktop/session/`，桌面应用归 `desktop/apps/`，外观与输入环境归 `desktop/environment/`；存储域服务（btrbk、btrfs-scrub、smartd）归 `storage/`。目录与命名空间不要求一一对应（`apps/`、`desktop/session/`、`storage/` 下都有 `services'.*` 模块），主机只通过选项开关使用模块，不感知文件位置。

Karabiner 配置位于 `home/darwin/apps/karabiner.nix`，不设独立开关：Homebrew 启用且 `casks` 包含 `karabiner-elements` 时才生效，Homebrew 声明列表是唯一来源。激活在 Home Manager 的 `writeBoundary` 之后、`linkGeneration` 之前执行（`dry-run` 不写文件）：先把已有 JSON 备份为 `karabiner.json.hm-bak`（覆盖上一份的独立副本），再把 Nix 生成的内容写到 `${xdg.configHome}/karabiner/karabiner.json`，两者均为 `0600` 普通文件。配置可直接手改，但会在下次激活时被 Nix 配置替换，原内容留在备份中；模块不做旧目录链接的自动迁移。

桌面应用（Firefox、Kitty 等）的启用开关统一放在 `desktop'.apps.<app>.enable`，由 `modules/nixos/desktop/apps/` 下的应用模块定义，模块内部通过 `hm'` 设置 Home Manager 的原生选项。不要为单个用户应用在 Home Manager 里新建自定义命名空间。

跨平台的开发 CLI 工具集（uv、direnv、Nix 工具链）由 `tools'.dev.enable` 控制，安装、集成和持久化配置收敛在 `modules/common/tools.nix`；gh、lazygit 与 git-trim 是 git 工作流基线，随 git 和 delta 放在 `home/common/git.nix`；Shell 专属的 `uv` / `uvx` 补全分别放在 `home/common/fish.nix` 和 `home/common/zsh.nix`，并按命令是否存在加载。NixOS 的 AI 开发工具集（ChatGPT 桌面端、Claude Code、Codex、DeepSeek CLI 和 ZCode）由 `tools'.ai.enable` 控制，配置收敛在 `modules/nixos/apps/ai-tools.nix`；其中 ChatGPT（`chatgpt`）、DeepSeek CLI（`dsh`）和 ZCode 使用 `llm-agents` input 提供的包，持久化直接声明在 `preservation'.user` 下。其他带开关的内容不放入 `home/common/` 基线。`just` 属于所有主机共用的基线工具，放在 `home/common/misc.nix`。XDG 用户目录是桌面能力，由 `desktop'.xdg-user-dirs.enable` 控制，不放进 `home/nixos/` 基线。

## 多设备配置

`helpers/constants/user.nix` 中的 `myvars.username` 是所有主机的唯一用户名来源。需要引用当前用户时：

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
- 桌面共用状态（GTK、dconf、密钥环等）跟随生成或消费它们的桌面功能声明，例如 GTK/dconf 放在 `desktop/environment/themes.nix`；由上游模块间接触发的系统服务（如 GNOME Keyring 会被 niri 生态开启、GVfs 会被桌面基线应用开启）也拥有自己的服务模块和 `services'.<name>.enable` 开关，持久化按最终服务状态判定
- 服务自己的状态由服务模块声明，例如 VNStat 放在 `services/vnstat.nix`；桌面功能和应用由 `desktop/` 下定义各自开关的模块声明，例如 Firefox 放在 `desktop/apps/firefox.nix`
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

格式化用 `just fmt` 或 `nix fmt`（nixfmt-rs）。

常规检查：

```bash
nix fmt . -- --check
deadnix --fail .
```

完整检查（含所有主机求值）：

```bash
nix flake check --all-systems --no-build
```

flake 的 `checks` 输出包含 `format`（nixfmt-rs）、`deadnix`、`darwin-eval` 和 `hosts-eval`：`nix flake check` 会深度求值 `nixosConfigurations`，但不会求值 `darwinConfigurations`，后者由 `darwin-eval` 强制覆盖；`hosts-eval` 按 `lib/eval-tests.nix` 的清单断言各主机的角色与关键配置值（有意改变行为时同步更新清单）。`--no-build` 时 checks 只求值不执行，本地检查用 `just check`。

不带 `--all-systems` 时，flake check 只求值与本机架构相同的主机（例如在 Apple Silicon 上会跳过全部 NixOS 主机）。如果工作区包含尚未纳入 Git 的新文件，应在包含完整工作区内容的临时非 Git 副本中运行 flake 检查，避免 Nix 的 Git flake 读取器遗漏这些文件。

检查全部在本地运行：`just check` 包含格式检查、未使用声明和所有主机求值。仓库不设远程 CI 检查，GitHub 上仅保留 issue/PR 的标签和依赖更新自动化。
