# AGENTS.md

本文件记录本仓库的实现约定，供参与修改配置的开发者和自动化代理使用。安装和日常使用说明放在 `docs/`，不要把内部模块设计写进安装指南。

## 工作边界

- 修改前先检查相关主机、模块和文档的现状，保留与当前任务无关的本地改动。
- 除非用户明确要求，不要执行 `git add`、提交、推送、创建或修改 PR。
- 配置改动完成后，至少运行格式检查、`deadnix` 和 Nix 语法检查（见「验证」）。

## 仓库结构

```
flake.nix             Flake 入口：导出所有主机、formatter 和模块
vars/default.nix      全局变量：用户名、姓名、邮箱、时区、密码哈希、SSH 公钥
hosts/
  darwin/<host>/      nix-darwin 主机（default.nix）
  nixos/<host>/       NixOS 主机（default.nix + hardware.nix）
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
Justfile              switch / check / update / gc / fmt 等常用命令
```

装配与自动发现：

- `hosts/default.nix` 把 `hosts/<平台>/<主机名>/default.nix` 构造成一台主机，目录名即 flake 里的主机名。
- 每台主机注入同一组 `specialArgs`：`inputs`、`myvars`、`hostName`、`platformName`；Home Manager 通过 `extraSpecialArgs` 收到同一组，并以 `backupFileExtension = "hm-bak"` 接入主用户。模块和 Home Manager 文件可以直接取用这些参数。
- `modules/default.nix` 递归扫描 `modules/common/` 和当前平台目录：含 `default.nix` 的目录作为单个模块整体导入，否则继续下钻；普通 `.nix` 文件直接导入。新增模块放入正确的职责目录即可，无需登记。
- `home/default.nix` 递归导入 `home/common/` 和平台目录下的所有 `.nix` 文件。
- NixOS 主机的 `hardware.nix` 持有硬件探测结果、内核、引导和 `storage'.disko` 磁盘参数（`device`、`espSize`、`swapSize`、`luks.enable`）。

## 模块和命名约定

自定义选项使用带撇号的命名空间，避免和 NixOS、nix-darwin 或 Home Manager 的原生选项混淆：

| 命名空间 | 职责 | 定义位置 |
| --- | --- | --- |
| `core'` | 主机与主用户元数据：hostName、timeZone、hashedPassword、sshAuthorizedKeys | `modules/*/system/core.nix` |
| `system'` | 系统级杂项（darwin 系统偏好 `system'.defaults`） | `modules/darwin/system/` |
| `apps'` | 应用级系统配置（darwin Homebrew `apps'.homebrew`） | `modules/darwin/apps/` |
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
options.services'.example.enable = lib.mkEnableOption "Example service";

config = lib.mkIf cfg.enable {
  # module-owned configuration
};
```

模块的自定义 `enable` 是功能边界。若它负责启用底层服务，底层 `enable` 应直接设置为 `true`，避免自定义开关和原生开关产生分叉。`lib.mkDefault` 只用于确实需要让主机覆盖的默认值。

一个模块文件只承载一个功能或服务。被多个桌面依赖的底层能力（如 Greetd、Bluetooth、UPower）拆成独立模块并持有自己的持久化条目，需要它们的模块或主机显式开启对应开关；持久化跟随最终服务状态判定，无论由哪个开关打开。

PostgreSQL 文件按仓库约定放在 `modules/nixos/apps/`，但它是系统服务，所以选项仍使用 `services'.postgresql`。

Karabiner 配置位于 `home/darwin/apps/karabiner.nix`，不设独立开关：Homebrew 启用且 `casks` 包含 `karabiner-elements` 时才生效，Homebrew 声明列表是唯一来源。激活脚本把生成的 JSON 写到 `${xdg.configHome}/karabiner/karabiner.json`，它是普通可编辑文件，不链接到 Nix store。同目录的 `.nix-generated-karabiner.json` 记录上次生成内容：规则未变就保留手动和图形界面的修改，规则变化时先把当前 JSON 备份为 `karabiner.json.hm-bak` 再写入新配置。JSON、记录文件和新备份均使用 `0600` 权限；记录文件通过临时文件替换，兼容旧的只读文件。

初始化在 Home Manager 的 `writeBoundary` 之后、`linkGeneration` 之前执行，`dry-run` 不写文件。迁移旧目录链接时先完整复制并去引用到临时目录，成功后再换成普通目录，原目录数据保留；发布失败则恢复旧链接。旧 JSON 链接的备份必须是独立普通文件，不能依赖 Nix store 或覆盖备份链接指向的文件。

桌面应用（Firefox、Kitty 等）的启用开关统一放在 `desktop'.apps.<app>.enable`，由 `modules/nixos/desktop/` 下的应用模块定义，模块内部通过 `hm'` 设置 Home Manager 的原生选项。不要为单个用户应用在 Home Manager 里新建自定义命名空间。

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

`docs/*安装指南.md`、`docs/*配置指南.md` 只描述用户完成安装、初始化和升级所需的步骤，以及日常使用的注意事项。模块目录、命名空间、开关职责、持久化策略等内部设计写在本文件，不要重复放进指南。

## 验证

常规检查：

```bash
alejandra .
deadnix --fail .

for file in $(rg --files -g '*.nix'); do
  nix-instantiate --parse "$file" >/dev/null || exit 1
done
```

完整检查（含所有主机求值）：

```bash
nix flake check --no-build
```

如果工作区包含尚未纳入 Git 的新文件，应在包含完整工作区内容的临时非 Git 副本中运行 flake 检查，避免 Nix 的 Git flake 读取器遗漏这些文件。

本地的 `just check` 等价于 CI 加主机求值；格式化用 `just fmt` 或 `nix fmt`。CI（`.github/workflows/check.yml`）只跑格式、未使用声明和 Nix 语法三项检查。
