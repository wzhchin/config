# Change: <change-slug>

Status: draft

Archive: Move `docs/changes/now/<change-slug>/` to `docs/changes/ended/<change-slug>/` after verification and merge review pass, preserving this spec and its evidence.

## Goal

<State one user-visible result, or the refactor improvement and behavior to preserve.>

## Non-goals

- <State excluded behavior.>

## Affected specs

- `docs/specs/<spec-key>.md`

## User stories

### US1: <P1 title>

Priority: P1

As a <role>, I want <action>, so that <value>.

Independent verification: <Describe how to test and demonstrate this story alone.>

## Requirement changes

<Use None for a pure refactor; otherwise repeat the following entry for each requirement change.>

### <spec-key>/R1: <requirement name>

Operation: <add | modify | remove>

Stories: US1

Before: <None for add; for modify or remove, copy the current requirement and affected scenarios with their IDs.>

Expected behavior:

The system MUST <one observable post-change behavior, including the expected outcome after a removal>.

#### <spec-key>/R1/S1: <scenario name>

Given <observable initial state>

When <user action or system event>

Then <observable result>

## Preservation checks

<For a pure refactor, list existing requirement or scenario references, or observable invariants when specs are absent, and how each will be verified. Otherwise use None.>

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

<Link relevant entries in docs/lessons-learned/<topic-slug>.md, or use None when there is no qualifying lesson.>
