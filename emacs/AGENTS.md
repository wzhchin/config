# Emacs 配置规格与修改说明

## 目标与启动模式

- `ee` 是基础编辑模式，目标是体感即开即用：启动后能立即编辑，尽量缩短看到界面和首次操作前的等待。不以与 Vim 的启动毫秒数相同作为硬性指标。
- 基础模式保留 Evil、Vertico、which-key 和按需调用的 Consult。启动时读取 `chin-first-call.el` 和 `chin-idle.el`，由各文件登记功能的加载入口；按键或点击触发对应操作时才加载按需功能，例如首次打开补全提示时加载 Vertico。
- `ee` 默认不加载 Eglot、Corfu、`consult-xref` 或语言服务器。把包目录加入 `load-path` 不等于加载包。
- `eee` 是 IDE 模式，在基础配置之上通过 `--chin-dev` 加载 `chin/chin-dev.el`，启用 Eglot、Corfu 等开发功能。
- 在 `ee` 中显式调用 `M-x dev-mode`，可以为当前编程缓冲区加载并启用开发功能；它的自动加载声明不能提前加载 `chin-dev`。

## 文件职责与加载时机

- `early-init.el`：包系统和界面初始化前必须生效的设置。
- `init.el`：整体加载编排和基础编辑设置；启动时读取 `chin-first-call.el`、`chin-idle.el`，登记 `--chin-dev` 的加载入口。
- `chin/chin-first-call.el`：`ee` 启动时读取，登记按键和交互命令所需功能。Vertico 在首次补全提示前加载；Consult 等命令在实际调用时加载；`point-stack` 在第一次跳转前加载并记录起点。
- `chin/chin-idle.el`：`ee` 启动时读取；文件内各功能自行决定空闲多久后加载。目前 which-key 在首次空闲时启用。
- `chin/chin-dev.el`：只由 `eee` 或显式 `dev-mode` 加载，包含 IDE 功能。
- `site-start.el`：Windows 安装位置使用的站点启动文件，不属于 `ee` 的普通模块加载链。

## 修改约束

- 启动编排集中在 `init.el`；原 `chin/chin-start.el` 的职责已合入这里。按功能所属的模式和加载时机放置配置。
- 新功能若会增加 `ee` 启动或首次交互的等待，先判断能否在 `chin-idle.el` 中安排自己的空闲时间，或在对应操作实际调用时加载。不要为所有空闲功能设一个统一时间，也不要把整个配置文件的读取延后代替功能的按需加载。
- 保持基础模式和 IDE 模式的边界；不要为了整理文件而提前加载扩展包。

## 验证要求

- 检查 `ee` 路径：`init.el` 加载后，`chin-first-call` 和 `chin-idle` 均已读取，但 Vertico、which-key、`point-stack` 和 `chin-dev` 均未加载；首次补全提示前加载 Vertico，第一次跳转前加载 `point-stack` 并记录起点。
- 检查空闲定时器触发后 which-key 启用；新增空闲功能时分别检查其加载时间。
- 检查基础模式在补全和空闲功能加载后，仍未加载 Eglot、Corfu 和 `consult-xref`。
- 检查 `ee .`：Dired 即使先于 Evil 加载，也能在 Evil 启用后获得快捷键配置。
- 检查 `eee` 路径：传入 `--chin-dev` 后，`chin-dev`、Eglot 和 Corfu 已加载；保留 `M-x dev-mode` 的按需入口。
- 改动后运行相应检查和 `git diff --check`，确认没有带入其他目录的修改。
