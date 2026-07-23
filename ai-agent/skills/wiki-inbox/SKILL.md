---
name: wiki-inbox
description: Record what was done in the current session to a dated log folder under $CHIN_PUB_WIKI_DIR/inbox/. Use when user says "/log", "log this", "record this", "save a log", "write it down", or wants to archive what they've been working on.
---

# Wiki Inbox

Record the current session's work into a structured log folder under `$CHIN_PUB_WIKI_DIR/inbox/`.

## Instructions

### Step 1: Check context availability

Review the current conversation to determine if there is meaningful work context (commands run, files modified, problems solved, decisions made).

**If there is no task context** (user invoked `/log` at the start or without prior activity):

- Tell the user: "当前没有任务进行，无法生成日志。"
- **STOP. Do not create any files.**

### Step 2: Generate slug and create folder

1. Based on the conversation context, generate a short English slug that captures the essence of the work. Use lowercase, hyphens, and keep it concise.
2. Construct the folder name: `<yymm-dd>-<slug>` (today's date in `yymm-dd` format).
3. Full target path: `$CHIN_PUB_WIKI_DIR/inbox/<yymm-dd>-<slug>/`
4. **If the folder already exists**: append a sequential number, e.g. `<yymm-dd>-<slug>-2/`

### Step 3: Compose README.md

Write `README.md` in the target folder following this template:

```markdown
# <English Title Summarizing the Work>

- **日期**: <YYYY-MM-DD HH:MM — current date and time, precise to minute>
- **主机**: <output of `hostname`>
- **工作目录**: <current working directory>
- **上下文来源**: 对话推断

## 做了什么 (What)

<Summarize what was done in this session. Be specific: list operations, changes, outputs produced. Use bullet points if multiple items. When a step involved running a command, include the command in a `bash code block` along with key output lines and a brief explanation of what the output means.>

## 为什么做 (Why)

<Background and motivation for this work. Omit this section if not apparent from context.>

## 怎么做的 (How)

<Key investigative or troubleshooting commands, not all commands. For each command: show it in a `bash code block`, include key output lines, and explain what the output tells us. Omit this section if straightforward and covered by "What".>

## 关键决策

<Important choices made and reasons. Omit if none.>

## 遇到的问题

<Problems encountered and how they were resolved. When a problem was diagnosed or fixed via command, include the command in a `bash code block` with key output and explanation. Omit if none.>

## 后续 TODO

<Unfinished items or follow-up tasks. Omit if none.>

## 附件

- `<filename>` — <one-line description>
```

**Section rules**:
- Sections marked "Omit if none" MUST be removed entirely if there is nothing to write.
- "上下文来源" should be "对话推断" when inferred from conversation, or "手动记录" if user provided description manually.
- Get hostname by running `hostname`.
- Get current time by running `date '+%Y-%m-%d %H:%M'`.

### Step 4: Recommend attachments

1. Based on the conversation context, identify files that would be useful to archive:
   - Configuration files that were modified
   - Scripts or code that were created
   - Output files, logs, or reports that were generated
   - Any artifact that would help understand or reproduce the work

2. Present the list to the user:
   ```
   建议复制以下文件到日志文件夹：
   1. path/to/file1 — 一句话说明
   2. path/to/file2 — 一句话说明

   是否复制？可以选择：全部 / 编号 / 跳过
   ```

3. Wait for user confirmation before copying.

4. Copy (not move) confirmed files into the log folder using `cp`.

5. Update the "附件" section in README.md with the actual copied files.

If no files seem worth attaching, skip this step and omit the "附件" section.

### Step 5: Confirm

After everything is done, show the user:

```
日志已记录到: inbox/<yymm-dd>-<slug>/
- README.md ✓
- <attachment files> ✓ (if any)
```
