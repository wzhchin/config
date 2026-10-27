FSA='# 知识库文件系统架构与规范指南 

## 核心设计哲学

使用 PARA 与 CODE 的笔记方法。

---

## 文件目录树

### 整体目录

```text
chnot-vault/                                 # 知识库根目录 (Git 仓库)
├── AGENTS.md                                # AI 维护指南 (LLM-Wiki 维基管理员协议)
├── .chnots/                                 # 知识库脚手架与配置
│   ├── templates/                           # 标准化预设模板
│   └── scripts/                             # 工作脚本
├── cpts/                                    # Code -- Captures 
│   ├── archives/                            # 存档目录  
│   └── 2609-01-<slug>/                      # 快速捕获 Chnot
├── prjs/                                    # PARA -- Projects 有明确截止期的交付任务。
│   ├── archives/                            # 存档目录  
│   └── login-v2/                            # 短期项目 Chnot
├── areas/                                   # PARA -- Areas 需要持续维持标准的岗位职责。
│   ├── archives/                            # 存档目录 
│   └── devops-infra/                        # 长期 Area Chnot
└── rsrs/                                    # PARA -- Resources 通用客观知识资产空间。以 **Theme 专题或原子条目** 组织。
    ├── .git/ 
    ├── archives/                            # 存档目录 
    └── pkm-methodology/                     # 可复用资产 Chnot
```

### Chnot

Chnot 是笔记的组成单元，可以嵌套子 Chnot。每个 Chnot 应该有一个主题。
组成结构
```text
- chnot
  - TAGS.lines: [必须] 用来记录 tags
  - CHNOT.md: [可选] 担任 README 的角色
  - TOENT.yaml: [可选] 用来记录提醒
  - _assets/: [可选] 每个主题的附件记录到当前 chnot 下，严禁建立全局附件中心
```

#### TAG.lines 与元数据规范

1. 格式法则
- 纯文本文件，每行一个 tag，无 YAML 语法包裹（无需 `- `、引号、键值对）；
- 空行与 `#` 注释行自动忽略；
- 首行必须包含类型 tag（如 `project`, `area`, `theme`, `concept`）。

2. 标签分类约定
| Tag 类别 | 用途 | 示例 |
| :--- | :--- | :--- |
| **类型** | 内容性质 | `project`, `area`, `theme`, `concept`, `how-to`, `tutorial`, `reference`, `moc` |
| **状态** | 生命周期 | `seed`, `growing`, `evergreen`, `archived` |
| **领域** | 技术栈/知识域 | `linux`, `btrfs`, `k8s`, `go`, `rust`, `ai`, `pkm`, `finance` |
| **场景** | 实操语境 | `troubleshooting`, `performance`, `security`, `architecture` |

### 目录职责与边界区分

> **Area vs Resource 快速判别**：
> - **Area（责任）**：“我对什么结果负有长期责任？三个月不管会失控吗？” ➔ **会**。
> - **Resource（资源）**：“隐去名字对别人有用吗？放一年不管会出事吗？” ➔ **依然有用，不会出事**。

---

## 知识演化与变更流转规范

1. **原地演进**：直接修改原文件更新认知，不保留 `v1-old.md` 等版本冗余，Git 记录演变历史。
2. **破坏性变更**：正文以当前最新标准为主，使用 `> [!WARNING]` 或 `> [!NOTE]` 提示块说明历史版本差异。
3. **原子拆分**：单篇笔记膨胀时，拆分成独立的原子概念卡片，原文件降级为 MOC 导读页。
4. **失效归档**：彻底废弃的技术整目录移至 `archives/resources/`，打上 `archived` tag。
'

spec_print() {
  echo "$FSA"
}
