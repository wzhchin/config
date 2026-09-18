# Change: <change-slug>

Status: draft

Archive: Move `docs/changes/now/<yyyy-mm-dd>-<change-slug>/` to `docs/changes/ended/<yyyy-mm-dd>-<change-slug>/` after verification and merge review pass, preserving this proposal and its evidence.

## Purpose

<State one change goal and its user value, or the refactor improvement and behavior to preserve.>

## Non-goals

- <State excluded behavior.>

## Affected specs

- `docs/specs/<spec-key>.md`

## User stories

### US1: <P1 title>

Priority: P1

As a <role>, I want <action>, so that <value>.

Independent verification: <Describe how to test and demonstrate this story alone.>

#### US1/S1 — <acceptance scenario name>

Given <observable initial state>

When <user action or system event>

Then <observable result>

## Requirement changes

<Use None for a pure refactor; otherwise repeat the following entry for each requirement change.>

### <spec-key>/R-<meaningful-kebab-slug>

Operation: <add | modify | remove>

Stories: US1

Acceptance scenarios: US1/S1

Before: <None for add; for modify or remove, copy the exact current requirement sentence.>

After: <For add or modify, write the exact final requirement sentence for the canonical spec; for remove, use None.>

## Preservation checks

<For a pure refactor, list existing requirement references, or observable invariants when specs are absent, and how each will be verified. Otherwise use None.>

## Boundary checks

Link applicable cases to an acceptance scenario or preservation check.

- Empty or missing input: <not applicable, or expected behavior and verification reference>.
- Repeated action or idempotency: <not applicable, or expected behavior and verification reference>.
- Permission or ownership: <not applicable, or expected behavior and verification reference>.
- Dependency failure: <not applicable, or expected behavior and verification reference>.
- Existing state or behavior conflict: <not applicable, or expected behavior and verification reference>.

## Clarifications

None.

## Verification evidence

Pending.

## TDD exceptions

None.

## Completion verification

Pending.

## Lessons learned

<Link relevant files under docs/lessons-learned/<topic-slug>/<yyyy-mm-dd>-<lesson-slug>.md, or use None when there is no qualifying lesson.>
