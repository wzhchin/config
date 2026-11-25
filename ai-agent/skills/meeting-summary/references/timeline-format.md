# Timeline Format Specification (`<slug>-timeline.md`)

`<slug>-timeline.md` is a **chronological, high-fidelity** record of the meeting. It combines a scannable timeline index with dense per-segment notes so readers can jump to any timestamp and recover every substantive fact, argument, disagreement, and decision without re-reading raw ASR text.

---

## 1. File Structure

```markdown
# <Meeting Title>

- **Slug**: `<slug>`
- **Source**: `<source-filename-or-path>`
- **Duration**: `00:00:00 -- HH:MM:SS`
- **Participants**: Speaker A, Speaker B, ... (or `Unknown / 未标注说话人`)

## Timeline

- [ 00:00:00 -- 00:02:15 ] misc opening-and-audio-check
- [ 00:02:15 -- 00:08:40 ] sync q4-latency-status
- [ 00:08:40 -- 00:21:10 ] discuss cache-invalidation-options
- [ 00:21:10 -- 00:24:30 ] decision adopt-write-through-with-ttl
- [ 00:24:30 -- 00:28:00 ] action rollout-schedule-and-owners

## Details

### [ 00:00:00 -- 00:02:15 ] misc opening-and-audio-check

- 参会人陆续入会、调试麦克风，确认本次会议聚焦订单查询延迟优化。

### [ 00:02:15 -- 00:08:40 ] sync q4-latency-status

**主题**：订单查询接口 P99 延迟现状与排查数据

- **核心指标**：[张明] 同步近 7 天 `/api/v2/orders` P99 延迟从 220ms 涨至 840ms，高峰 QPS 约 1,800。
- **瓶颈定位**：慢查询日志显示 72% 耗时来自 `orders` 与 `order_items` 的三表联查，MySQL 主库 CPU 在晚 8 点达到 85%。
- **业务约束**：双十二压测前（12-05）需将 P99 压回 300ms 以内，且不能引入超过 5 秒的数据读取延迟。
```

---

## 2. Syntax Rules

### Timeline Index Line (Strict)

Every bullet under `## Timeline` MUST match:

```text
- [ HH:MM:SS -- HH:MM:SS ] <type> <segment-slug>
```

- **Brackets & spacing**: Single space after `[`, single space before `]`, ` -- ` with single spaces around the double hyphen.
- **Timestamp format**: Zero-padded `HH:MM:SS` (e.g., `00:05:12`, `01:23:45`).
  - Normalize `MM:SS` → `00:MM:SS`.
  - Normalize SRT/VTT milliseconds (`00:05:12,800` → `00:05:12`) and float seconds (`312.4` → `00:05:12`).
  - If the source transcript has **no timestamps at all**, use `[ N/A -- N/A ]` and note `Timestamps: unavailable` in the top metadata. Never invent timestamps.
- **`<type>`**: Must be one of the 7 lowercase English shortcodes defined in Section 3.
- **`<segment-slug>`**:
  - Unique across the entire file.
  - No whitespace (use lowercase `kebab-case`, e.g., `cache-invalidation-options`; concise no-space CJK slugs like `缓存失效方案对比` are also acceptable if preferred, but keep style consistent within a file).
- **1-to-1 Pairing**: Every `- [ ... ] <type> <segment-slug>` in `## Timeline` MUST have a matching `### [ ... ] <type> <segment-slug>` heading in `## Details` in the same order.

---

## 3. `<type>` Taxonomy

Use the primary activity dominating the segment. When a segment cleanly shifts from discussion into an explicit decision or task assignment, split it so `decision` and `action` segments remain easy to locate.

| `<type>` | Chinese Equivalent | When to Use |
| :--- | :--- | :--- |
| `sync` | 信息同步 | Opening context, progress reports, metric/status updates, demos, one-way walkthroughs. |
| `discuss` | 问题讨论 | Problem diagnosis, debating causes, weighing pros/cons, brainstorming, surfacing blockers or risks. |
| `review` | 方案评审 | Presenting and scrutinizing a concrete technical/product/business design, PRD, RFC, or architecture. |
| `decision` | 决策确认 | Explicitly choosing an option, confirming scope/priority/policy, or rejecting a proposal. |
| `action` | 任务分工 | Assigning tasks, owners, due dates, milestones, deliverables, or cross-team dependencies. |
| `qa` | 答疑澄清 | Brief Q&A clarifying specific facts, edge cases, terminology, or existing behavior. |
| `misc` | 杂项过场 | Greetings, mic/screen troubleshooting, waiting for attendees, tangents, breaks. |

---

## 4. High-Fidelity Extraction Rules

"High-fidelity dense notes" means **zero loss of substantive information** while removing conversational filler and repetition:

1. **Attribute speakers**: Prefix key claims, objections, and commitments with `[说话人]` whenever the transcript identifies speakers (e.g., `[李华]` or `[Speaker 2]`).
2. **Keep hard facts intact**: Never round away or generalize concrete numbers, thresholds, dates, versions, table/service names, budgets, or SLAs.
3. **Preserve reasoning & disagreements**:
   - Record *why* someone supports or opposes an idea, not just that "it was discussed".
   - Explicitly capture **分歧点** (who holds position A vs. position B) and **被否决/暂缓的方案** plus the rejection reason.
4. **Preserve caveats & open items**: Capture preconditions ("前提是…"), dependencies, risks, and unresolved questions (`[待确认]`).
5. **Adapt facets to `<type>`** (omit any facet that did not occur; never write empty placeholders like `分歧：无`):
   - `sync`: 核心信息、关键数据/现状、边界或变化
   - `discuss`: 问题定义、各方观点与论据、分歧点、备选/否决方案、阶段性共识或遗留问题
   - `review`: 评审对象与核心设计、质询与挑战点、需修订项
   - `decision`: 最终结论、决策依据、适用前提/边界、被否决项
   - `action`: 任务内容、负责人、截止时间/排期、依赖与交付物
   - `qa`: 提问（含提问人）→ 回答（含回答人）→ 补充边界
   - `misc`: 单行简述即可（不展开）
6. **Honest uncertainty**: Fix unambiguous ASR typos silently using context, but mark genuinely unintelligible or conflicting audio as `[听不清/待确认]`.

---

## 5. Complete Segment Example (`discuss` + `decision` + `action`)

```markdown
### [ 00:08:40 -- 00:21:10 ] discuss cache-invalidation-options

**主题**：订单查询缓存引入方案对比（旁路缓存 vs 写穿缓存 vs ES 同步）

- **方案 A（ES 异步同步）— 被否决**：
  - [王磊] 提议将订单宽表通过 Canal 同步至 ES，彻底卸载 MySQL 联查压力。
  - [李静] 反对：现有 ES 集群无空闲节点，扩容+双写对账至少需 3 周，赶不上 12-05 压测；且异步延迟在高峰期可能突破 5 秒红线。
- **方案 B（Redis Cache-Aside）— 存在分歧**：
  - [张明] 提议按 `order_id` 缓存组装后的详情 JSON，更新时删缓存。
  - [陈涛] 担心并发读写导致旧数据回填，且列表页按 `user_id` 分页查询无法直接命中。
- **方案 C（Redis Write-Through + 短 TTL）— 获得主流认可**：
  - [李静] 建议仅缓存高频的“最近 30 天订单摘要”，写入数据库成功后同步刷新 Redis，TTL 设 10 分钟兜底；历史冷数据仍走 MySQL 从库。
  - [张明] 补充统计：最近 30 天订单占总查询量的 88%，该方案可覆盖绝大部分流量。
- **待确认风险**：需压测确认高峰写入链路增加一次 Redis 写操作对下单 RT 的影响（预期 < 5ms）。

### [ 00:21:10 -- 00:24:30 ] decision adopt-write-through-with-ttl

**主题**：拍板采用“最近 30 天热数据 Write-Through + 冷数据走从库”方案

- **最终结论**：本期采用方案 C（Redis Write-Through + 10 分钟 TTL），冷数据查询切至只读从库；ES 宽表方案延后至 Q1 评估。
- **前提条件**：下单链路新增 Redis 写入需做异步降级开关，Redis 异常时不得阻塞下单主流程。

### [ 00:24:30 -- 00:28:00 ] action rollout-schedule-and-owners

**主题**：开发排期与压测分工

- **[张明]**：11-28 前完成缓存 Key 设计与降级开关评审文档，同步 DBA 确认从库延迟监控。
- **[陈涛]**：12-02 前完成 Write-Through 代码开发与单元测试。
- **[王磊]**：12-04 组织全链路压测，验收 P99 <= 300ms 且从库延迟 <= 2s。
```
