# Mind Map Format Specification (`<slug>.mind.md`)

`<slug>.mind.md` is a **thematic, logically organized** overview of the meeting rendered as a pure nested Markdown bullet list. While `<slug>-timeline.md` follows chronological time, `<slug>.mind.md` groups scattered discussions by topic tree so readers grasp the entire meeting structure at a glance.

---

## 1. Syntax Rules (Strict Compatibility)

To remain 100% compatible with Markdown mind-map renderers (Markmap, XMind Markdown import, Obsidian Mind Map) and outliners:

- **Pure unordered bullets only**: Every non-blank line MUST start with `"- "` (indented by multiples of **2 spaces**).
- **No other Markdown blocks**: Do NOT use `#` headings, YAML frontmatter, code fences, tables, blockquotes, or horizontal rules (`---`).
- **Single root node**: Use one top-level bullet (`- <Meeting Title>`) as the central node so mind-map tools render a single unified tree.
- **No skipped indent levels**: Never jump from 0 spaces directly to 4 spaces; always increase by 2 spaces per level.
- **No tabs**: Use spaces only.

---

## 2. Structuring Principles

1. **Group by topic, not by clock time**:
   - If the meeting discussed "缓存一致性" at `00:08:00` and revisited it at `00:42:00`, merge both under the same topic branch in the mind map.
2. **Omit `misc` noise**:
   - Drop audio checks, greetings, and off-topic chatter unless they produced a real constraint or decision.
3. **Keep nodes scannable**:
   - Prefer concise phrases over multi-sentence paragraphs (ideally <= 35 CJK characters or <= 15 English words per node).
   - Break complex points into parent → child sub-bullets instead of stuffing everything into one long line.
4. **Target depth of 3–5 levels**:
   - Level 0: Meeting title (root)
   - Level 1: Major topics + dedicated roll-up branches where applicable (`决策汇总` / `行动项` / `待确认与风险`)
   - Level 2: Sub-topics / dimensions (背景、方案、分歧、结论)
   - Level 3–4: Concrete facts, metrics, arguments, owners, deadlines
5. **Lightweight semantic tags**:
   - Use short inline prefixes only when they add scan value: `[决策]`, `[否决]`, `[分歧]`, `[风险]`, `[TODO]`, `[待确认]`.
   - Avoid cluttering every bullet with timestamps; `<slug>-timeline.md` is the source of truth for exact timestamps.
6. **Preserve key facts & attribution**:
   - Keep critical numbers, deadlines, and owners (e.g. `[TODO] 张明：11-28 前输出缓存 Key 设计与降级方案`), even though wording is tighter than in `<slug>-timeline.md`.

---

## 3. Complete Example (`<slug>.mind.md`)

```markdown
- 订单查询延迟优化评审（2026-11-24）
  - 背景与现状
    - `/api/v2/orders` P99 延迟从 220ms 升至 840ms（高峰 QPS 1,800）
    - 瓶颈：72% 耗时来自三表联查，主库晚高峰 CPU 达 85%
    - 目标与红线
      - 12-05 双十二压测前 P99 <= 300ms
      - 读取数据延迟 <= 5s
  - 缓存方案对比
    - ES 异步同步（王磊）
      - [否决] 集群无空闲节点，改造需 3 周赶不上 12-05
      - [风险] 高峰异步延迟可能超 5s 红线
    - Redis Cache-Aside（张明）
      - [分歧] 陈涛担心并发旧值回填，且 `user_id` 分页难命中
    - Redis Write-Through + 10min TTL（李静）
      - 仅缓存最近 30 天热数据（覆盖 88% 查询）
      - 历史冷数据切 MySQL 只读从库
      - [待确认] 高峰写 Redis 对下单 RT 影响（预期 < 5ms）
  - 关键决策
    - [决策] 本期采用 Write-Through + 10min TTL，冷数据走从库
    - [决策] 必须加异步降级开关，Redis 异常不得阻塞下单主流程
    - [决策] ES 宽表方案延后至 Q1 评估
  - 行动项
    - [TODO] 张明：11-28 前完成 Key 设计与降级文档，确认从库延迟监控
    - [TODO] 陈涛：12-02 前完成 Write-Through 开发与单测
    - [TODO] 王磊：12-04 组织全链路压测（P99 <= 300ms、从库延迟 <= 2s）
```
