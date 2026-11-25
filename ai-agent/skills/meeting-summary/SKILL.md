---
name: meeting-summary
description: >-
  Transform raw meeting transcripts (.txt, .srt, .vtt, .json, .md) into two
  structured artifacts: a high-fidelity chronological timeline with dense
  segment notes (<slug>-timeline.md) and a thematic mind map (<slug>.mind.md).
  Use when the user provides a meeting transcript or asks to summarize,
  structure, or transcribe/organize a meeting into a timeline and mind map
  (会议纪要、会议转写整理、会议时间线、会议脑图).
---

# Meeting Summary

Convert raw meeting transcripts into two complementary artifacts in the target output directory:

1. **`<slug>-timeline.md`** — Chronological, high-fidelity timeline index + dense per-segment notes preserving facts, speakers, reasoning, disagreements, decisions, and action items.
2. **`<slug>.mind.md`** — Thematic, clean nested-bullet mind map reorganizing the meeting by topic tree (for Markmap, XMind, Obsidian, or outliners).

Read the format specs before generating outputs:
- Timeline spec & `<type>` taxonomy: [references/timeline-format.md](./references/timeline-format.md)
- Mind map spec & structuring rules: [references/mindmap-format.md](./references/mindmap-format.md)

---

## Workflow

### Step 1: Inspect Input & Determine `<slug>`

1. Read the input transcript file (or pasted text). Supported formats include:
   - Timestamped plain text / Markdown (e.g. `[00:12:34] Speaker: ...`, `12:34 张三 ...`)
   - Subtitles (`.srt`, `.vtt`)
   - ASR JSON exports (Whisper, FunASR, Paraformer, Feishu, Tingwu, Tencent Meeting, etc.)
   - Un-timestamped transcripts (use `N/A` timestamps; never fabricate timestamps)
2. Determine `<slug>` and output directory:
   - If the user specified a `<slug>`, use it verbatim.
   - Otherwise derive a concise lowercase `kebab-case` slug from the input filename or meeting date + topic (e.g. `2611-24-cache-review`).
   - Write outputs to the user-specified directory, or alongside the input file (or current working directory if text was pasted).
3. Detect language: write summaries and mind-map nodes in the primary language of the meeting unless the user requests otherwise.

### Step 2: Full-Coverage Chunked Analysis (Anti-Compression)

Never skim or silently drop middle sections of a long transcript.

- **Short transcripts (<= 600 lines)**: Read in full in one pass.
- **Long transcripts (> 600 lines)**: Read sequentially in overlapping chunks (~500–700 lines per chunk, ~20 lines overlap). Extract segment boundaries and high-density notes for each chunk before moving to the next, then merge adjacent segments that belong to the same continuous discussion.
- **Normalize ASR noise carefully**:
  - Fix obvious phonetic / homophone ASR errors using domain context (e.g. `拉格` → `RAG`, `开八斯` → `K8s`), and normalize filler words (`嗯、那个、就是说`).
  - Never invent facts, numbers, or speaker names not supported by the transcript. Mark genuinely garbled or ambiguous passages as `[待确认]`.

### Step 3: Segment the Timeline

Split the transcript chronologically into contiguous segments whenever the **topic** or **activity `<type>`** shifts.

Allowed `<type>` shortcodes (use ONLY these 7):

| `<type>` | Meaning |
| :--- | :--- |
| `sync` | Information sharing, background, status update, metrics, demo |
| `discuss` | Problem analysis, trade-offs, brainstorming, open debate |
| `review` | Reviewing / challenging a specific technical, product, or business proposal |
| `decision` | Explicit resolution, final choice, scope/priority lock, or rejection |
| `action` | Action items, owners, deadlines, milestones, dependencies |
| `qa` | Short Q&A, factual or boundary clarification |
| `misc` | Small talk, audio/device setup, waiting, off-topic chatter, breaks |

Segment guidelines:
- Typical length: **2–15 minutes** per segment (shorter is fine for sharp `decision`, `action`, or `qa` beats; split long `discuss` blocks when sub-topics shift).
- Cover the entire meeting from start to end with **no silent gaps**. Include brief `misc` entries for non-substantive spans so the timeline remains faithful.
- Assign each segment a unique, no-space `<segment-slug>` (concise `kebab-case`, e.g. `cache-invalidation-tradeoff`).

### Step 4: Generate `<slug>-timeline.md`

Follow [references/timeline-format.md](./references/timeline-format.md) strictly:
- Top metadata block (`Slug`, `Source`, `Duration`, `Participants`).
- `## Timeline` index where every line strictly follows:
  ```markdown
  - [ HH:MM:SS -- HH:MM:SS ] <type> <segment-slug>
  ```
- `## Details` section with a 1-to-1 matching `### [ HH:MM:SS -- HH:MM:SS ] <type> <segment-slug>` subsection for every timeline entry.
- **High-fidelity standard** (dense bullet notes, not verbatim dialogue):
  - Preserve **who** raised each point/objection/commitment when speakers are identifiable.
  - Preserve **exact numbers, metrics, dates, system names, constraints, and caveats**.
  - Preserve **disagreements, rejected alternatives, and the reasons why** they were rejected or deferred.
  - Preserve **open questions, risks, and preconditions**.
  - Omit empty boilerplate labels; only write facets that actually appeared in the segment.

### Step 5: Generate `<slug>.mind.md`

Follow [references/mindmap-format.md](./references/mindmap-format.md) strictly:
- Pure nested Markdown unordered list (`- ` with 2-space indentation). No `#` headings, tables, code fences, or horizontal rules.
- Single root node (`- <Meeting Title>`) with thematic branches (`- topic` → `  - sub topic` → details).
- **Reorganize logically by topic**, merging scattered discussions of the same subject from different timestamps; omit `misc` chatter.
- Keep each bullet concise and scannable; prefix key semantic leaves with tags like `[决策]`, `[分歧]`, `[风险]`, `[TODO]`, `[待确认]` when helpful.

### Step 6: Validate Both Outputs

Run the bundled validator script before finishing:

```bash
python3 <skill-dir>/scripts/validate_outputs.py <slug>-timeline.md <slug>.mind.md
```

Fix any reported errors (and review any gap/structure warnings) before returning the final response. Report the generated file paths, segment count, covered duration, and any `[待确认]` items to the user.
