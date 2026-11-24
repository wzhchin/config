---
name: meeting-summary
description: >-
  Organize and summarize meeting recording transcripts and subtitles (.txt, .srt,
  .vtt, .md, .json, or exports from Feishu Minutes / Tongyi Tingwu / Zoom / Otter)
  into multiple structured Markdown files in the same directory: executive minutes
  with decisions and action items, topic-based discussion digest with viewpoints
  and risks, and a cleaned readable transcript with timestamps. Supports meeting
  type templates (regular sync, requirement/design review, interview/research,
  retrospective/postmortem). Use when the user asks to organize meeting recordings,
  summarize transcripts, clean up verbatim notes, or generate meeting minutes
  (整理会议录音, 会议纪要, 转写整理, 字幕整理, 逐字稿清洗, 会议总结).
---

# Meeting Summary (会议录音转写整理)

将会议录音的转写文稿或字幕文件（`.txt` / `.srt` / `.vtt` / `.md` / `.json`，含飞书妙记、通义听悟、Zoom、Otter 等常见导出格式）整理为**同一目录下的多份结构化 Markdown 文档**，兼顾高层速览、议题深挖与高保真原文溯源。

## 输出产物（固定写入源文件同目录）

设输入文件为 `<dir>/<prefix>.<ext>`（如 `2026-11-24-Q4规划会.srt`，则 `<prefix>` 为 `2026-11-24-Q4规划会`；若用户指定了统一前缀或输出目录，以用户指定为准），在 `<dir>/` 下生成 3 份互相链接的 Markdown 文件：

1. **`<prefix>-会议纪要.md`** — 面向快速同步与执行的精炼纪要（会议信息、一句话总结、核心结论与决策、行动项 Action Items、按会议类型适配的专属板块）。
2. **`<prefix>-讨论摘要.md`** — 按逻辑议题归类的深度讨论记录（议题背景、讨论要点、各方观点与立场、共识与分歧、遗留问题与风险）。
3. **`<prefix>-文字记录.md`** — 清洗校对后的可读版完整文字稿（去除口癖与字幕噪声、合理分段与标点、保留关键时间戳与发言人标识、高保真标注存疑片段）。

> 若用户明确只要其中部分文件，按用户要求裁剪；默认生成全部 3 份。

## 工作流

### 第 1 步：检查输入与确认上下文

1. 定位用户提供的转写/字幕文件（支持单文件，或用户指定的同一场会议多段分片文件）。
   - **音频文件兜底**：若用户提供的是 `.mp3` / `.m4a` / `.wav` / `.mp4` 等音视频文件而非转写文稿，先检查同目录是否已有同名转写/字幕文件；若没有，告知用户本技能以转写文本为主，询问是否由其先用听写工具导出文本/字幕，或对较短音频尝试直接听音整理。
2. 运行预处理脚本探测文件格式、字数、时长和发言人列表：
   ```bash
   python3 ~/.gemini/config/skills/meeting-summary/scripts/parse_transcript.py "<input_path>" --stats
   ```
3. 确定以下上下文信息（**能从文件名和文本开头直接判断的无需多问**；仅当关键背景缺失且会影响准确性时，做一次简短确认）：
   - **会议类型**：从内容自动识别或由用户指定，对应 4 套模板：
     - `例会 / 同步会`（默认通用模板）
     - `需求 / 方案评审`
     - `访谈 / 用户调研`
     - `项目复盘 / 事故复盘`
   - **参会人/发言人映射**：若原文仅标注 `发言人 1` / `Speaker A`，尝试结合自我介绍、互称和内容推断；不确定时保留原标签并在文件头部标注「待补全」。
   - **输出语言**：默认中文；若原文为英文或用户指定语言，遵循用户要求。

### 第 2 步：标准化与长文分块读取

为避免字幕编号/毫秒级时间轴浪费上下文或导致长会议遗漏后半段，按 `total_chars` 选择读取策略：

- **常规长度（标准化后 ≤ 15,000 字）**：直接导出标准化文本到临时文件并完整通读：
  ```bash
  python3 ~/.gemini/config/skills/meeting-summary/scripts/parse_transcript.py "<input_path>" --normalize --out "/tmp/meeting-summary-norm.txt"
  ```
- **超长会议（标准化后 > 15,000 字）**：使用脚本按发言人/段落边界自动分块（默认每块 12,000 字并带少量重叠），逐块通读提炼要点与清洗段落，最后全局合并归类，**严禁跳过中间片段**：
  ```bash
  python3 ~/.gemini/config/skills/meeting-summary/scripts/parse_transcript.py "<input_path>" --chunk-dir "/tmp/meeting-summary-chunks" --max-chars 12000
  ```

### 第 3 步：加载模板与清洗规范

在动笔前按需读取参考文件（渐进式加载）：

- 读取 [references/templates.md](./references/templates.md) 获取 `<prefix>-会议纪要.md`（对应会议类型）与 `<prefix>-讨论摘要.md` 的标准结构。
- 读取 [references/cleaning-rules.md](./references/cleaning-rules.md) 获取 `<prefix>-文字记录.md` 的去口癖、标点分段、术语校正、时间戳保留与高保真存疑规则。

### 第 4 步：生成 3 份 Markdown 文件

按以下顺序在源文件同目录写入（确保相互间的相对 Markdown 链接有效）：

1. **先写 `<prefix>-文字记录.md`**：
   - 通读全稿完成校对与清洗，确保所有专有名词、数据、时间戳和发言人映射先对齐统一。
   - 若为超长会议，可分块追加写入（`Append: true`），确保不丢失任何实质内容。
2. **再写 `<prefix>-讨论摘要.md`**：
   - 打破流水账顺序，按「逻辑议题」聚类重组；每个议题标注覆盖时间段（如 `[00:08:15 - 00:24:30]`）。
   - 显式呈现「各方观点（含发言人）」「已达成共识」「分歧/争议点」「待确认与风险」。
3. **最后写 `<prefix>-会议纪要.md`**：
   - 严格套用 [references/templates.md](./references/templates.md) 中匹配的会议类型模板。
   - 顶部包含 YAML Frontmatter（`title`、`date`、`meeting_type`、`source_file`、`participants`）及指向另外两份文档的相对链接。
   - **行动项（Action Items）铁律**：每一条必须尽量提取「事项、负责人、截止时间、出处时间戳」；原文未明确负责人或截止时间的，**一律写 `待确认`**，严禁臆测或编造。

### 第 5 步：质量自检与清理

1. 清理 `/tmp/` 下生成的临时标准化/分块文件（确保源文件目录内只有原始文件与本次生成的 3 份 Markdown 文件）。
2. 按以下清单核对生成结果：
   - [ ] 3 个文件均生成在源文件同目录，文件名与 `<prefix>` 一致，相对链接可点击跳转。
   - [ ] 无编造结论、无臆测负责人/日期，原文未明确项均标注 `待确认`。
   - [ ] 所有重要数字、指标、版本名、人名在三份文件间完全一致。
   - [ ] 讨论摘要覆盖了会议全程（核对首尾时间戳），没有漏掉后半段议题。
   - [ ] 文字记录保留了关键时间戳，且 ASR 听写严重失真处已标注 `[ASR存疑: 原文]`。
3. 向用户简明汇报：列出生成的 3 个文件路径、识别的会议类型与发言人映射情况，并高亮需要用户补充确认的事项（如匿名发言人、未定负责人/截止时间的待办、ASR 存疑处）。
