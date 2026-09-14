---
name: light-spec
description: Carry an approved change through test-first implementation or behavior-preserving refactors and fresh verification. Maintain current specs, active and completed changes, and reusable lessons under docs/. Use when explicitly requested or when the user is starting a new project or building an application from scratch. Recommended for defining the initial scope and acceptance criteria before implementation.
---

# Light Spec

Turn one approved change into verified code and current specifications.

## Keep project documents under docs

Use this layout relative to the project root, creating files and directories only when needed:

```text
docs/
├── constitution.md
├── changes/
│   ├── now/<change-slug>/spec.md
│   └── ended/<change-slug>/spec.md
├── specs/
│   ├── <slug>.md
│   └── <big-slug>/<slug>.md
└── lessons-learned/
    └── <topic-slug>/
        └── <yyyy-mm-dd>-<lesson-slug>.md
```

Keep `docs/specs/` as the source of truth for verified current behavior. Use a single `docs/specs/<slug>.md` for a small, self-contained topic. Group related topics under `docs/specs/<big-slug>/<slug>.md` when they belong to a larger capability; do not create a directory for every small spec.

Keep canonical specs compact: each contains only current requirements. Purpose, non-goals, user stories, acceptance scenarios, and boundary analysis belong to change records under `docs/changes/`. When a verified boundary outcome remains part of current behavior, express it as its own requirement rather than copying the change's boundary analysis or Given-When-Then scenario.

A spec key is its path relative to `docs/specs/` without `.md`: `login` or `accounts/login`. Inside a spec, identify requirements as `R1`, `R2`, and so on. Outside that file, reference them with the full key, such as `accounts/login/R1`, to distinguish topics with the same leaf name. Keep existing IDs and spec locations unless the approved change requires changing them.

Keep active proposals and evidence in `docs/changes/now/<change-slug>/spec.md`. After verification and merge review, move the entire change directory to `docs/changes/ended/<change-slug>/`, preserving its contents. Ended changes describe past work; current behavior belongs in `docs/specs/`.

Keep each reusable failed attempt or instructive success in its own Markdown file under `docs/lessons-learned/<topic-slug>/`. Store searchable metadata in YAML frontmatter and explanation and evidence in the Markdown body. The optional `docs/constitution.md` contains only project-specific constraints.

## Preserve the approval gate

Inspect the target repository and its local instructions before proposing files.

Read `docs/constitution.md` when it exists and honor its applicable project constraints. Follow the governing instruction hierarchy if it conflicts with this skill; do not silently rewrite it.

Read every affected file under `docs/specs/` and relevant lesson files under `docs/lessons-learned/<topic-slug>/` when they exist. Use earlier lessons to avoid repeating failed approaches under the same conditions.

This skill owns the general workflow. Use [references/constitution.md](references/constitution.md) only when a missing constitution would capture project-specific constraints worth retaining. Include those constraints in the proposal; do not copy this workflow into the project or create an empty constitution.

Establish the goal, non-goals, user value, affected capabilities, boundaries, and public behavior from the request and existing context. Ask only about missing information that affects the result.

Ask one blocking question at a time.

Mark unresolved high-impact information as `[NEEDS CLARIFICATION: <question>]`.

Prepare the complete proposal in the conversation or in `docs/changes/now/<change-slug>/spec.md` with `Status: draft`. Before approval, file edits are limited to this proposal and factual lesson entries from authorized investigation; preserve other active changes.

Obtain approval for the complete scope before implementation. Reuse explicit approval already given for that scope, including approval of a final revision; a new turn or workflow stage does not require renewed approval.

Do not treat silence, partial agreement, or approval of one section as approval of the complete draft.

Reopen approval only for changes to behavior, scope, acceptance criteria, or high-impact decisions that the user has not already authorized. Set the proposal back to `draft` and pause affected implementation until those changes are approved. Wording corrections, evidence updates, and implementation choices within the approved scope do not reopen approval.

Do not start implementation while an unresolved clarification remains. Use clarification markers only for actual pending decisions, never in template instructions or examples copied into a change.

## Draft one change

Use [references/change-spec.md](references/change-spec.md) as the change format.

Use a short kebab-case change slug that is unused in both `docs/changes/now/` and `docs/changes/ended/`, unless continuing the same active change.

Use short kebab-case names for spec topics, larger capability groups, lesson topics, and lesson slugs. List the exact affected spec file paths in the proposal.

State one change purpose with one goal and its user value. For a pure refactor, state the improvement and the behavior that must remain unchanged.

State explicit non-goals.

Write at least one P1 user story.

Make each user story independently implementable, testable, and demonstrable.

Give each user story at least one concrete Given-When-Then acceptance scenario. Identify change-local stories and scenarios as `US1` and `US1/S1`.

Write each requirement as one observable behavior with exactly one `MUST`. Include any condition that changes the result in the same normative sentence so the requirement remains testable without its change record.

Split distinct observable outcomes into separate requirements instead of nesting cases or scenarios in a canonical spec.

Give every requirement change at least one acceptance scenario and reference its `US1/S1` ID.

For each requirement change, identify its spec key, operation (`add`, `modify`, or `remove`), target requirement, related user stories, and acceptance scenarios. Reference requirements as `<spec-key>/R1`; keep existing IDs and allocate unused IDs for additions. Story and acceptance-scenario IDs are local to their change document.

For `modify` or `remove`, copy the exact current requirement sentence under `Before`. For `add`, use `Before: None`. This baseline identifies the approved replacement and lets the merge detect later changes.

For `add` or `modify`, put the exact final canonical requirement under `After`. For `remove`, use `After: None`.

A `remove` entry uses acceptance scenarios to specify and verify the observable outcome after removal. Do not merge that entry as a replacement requirement; represent any lasting replacement contract with a separate `add` or `modify` entry.

For a pure refactor, set requirement changes to `None` and list the existing requirements or observable invariants under preservation checks. Do not invent a behavior change to fit the template.

Check these boundary categories and include each applicable case:

- Empty or missing input.
- Repeated action or idempotency.
- Permission or ownership.
- Dependency failure.
- Conflict with existing state or behavior.

Do not invent a high-impact product, security, compatibility, or data decision.

Do not put implementation details, architecture, task lists, or terminal transcripts in a requirement.

Replace instructional placeholders before requesting approval; verification evidence may remain `Pending` until execution.

After approval, create or update the proposal at `docs/changes/now/<change-slug>/spec.md` with `Status: approved`, without overwriting another active change. Include its eventual move to `docs/changes/ended/<change-slug>/` in the approved scope.

Create the approved `docs/constitution.md` only when it is missing.

## Implement one vertical slice

Use RED-GREEN-REFACTOR for new or changed behavior, including the observable outcome of a removal. For work that only preserves behavior, use the refactor path below.

Select the highest-priority unfinished acceptance scenario.

Execute one RED-GREEN-REFACTOR slice before starting the next acceptance scenario.

### RED

Write one minimal automated test for one observable behavior.

Test through a public interface.

Mock only an external system boundary when real integration is impractical.

Run the narrow test.

Confirm that it fails because the specified behavior is absent.

If the test passes immediately, check that it exercises the intended scenario. If the behavior already exists, record that evidence and make no unnecessary product change; do not manufacture a failure.

If the test errors for an unrelated reason, fix the test setup and rerun it.

For a defect, make the test reproduce the defect before changing product code.

### GREEN

Write only the product code required to pass the current test.

Do not add behavior for later acceptance scenarios.

Update or retire tests for behavior explicitly replaced or removed by the approved scope; preserve coverage of unaffected behavior.

Run the narrow test.

Run the related test set.

### REFACTOR

Refactor only while all related tests pass.

Remove duplication or improve structure and names without adding behavior.

Rerun the related test set after each refactor step.

Record concise RED, GREEN, and REFACTOR evidence in the active change spec.

Link evidence to the acceptance-scenario ID and include the test path and name, commands, expected failure when applicable, and observed results. Explain when existing behavior makes RED unnecessary; record refactoring as not needed when no refactor was performed.

Repeat the cycle for the next acceptance scenario.

## Verify a behavior-preserving refactor

Identify the affected public behavior and run its related tests before changing product code. Add characterization tests first when coverage is missing; these tests document existing behavior and may pass immediately.

With a passing baseline, make the refactor and rerun the related tests. Record the preservation checks, test paths, commands, and before-and-after results. No failing test or TDD exception is required solely because the work preserves behavior.

If a check exposes a defect or the planned work changes observable behavior, separate that behavior change, obtain any missing scope approval, and use the RED-GREEN path for it.

## Control TDD exceptions

Allow a TDD exception only for a throwaway prototype, generated code, or a pure configuration change.

Require explicit user approval for the exception, reusing approval already given for the same scope. Behavior-preserving refactors follow their own verification path above and are not TDD exceptions.

Record its scope, reason, and reproducible alternative verification in the active change spec.

Reject “testing is difficult” and “time is short” as exception reasons.

## Record lessons while working

Use [references/lessons-learned.md](references/lessons-learned.md) when creating `docs/lessons-learned/<topic-slug>/<yyyy-mm-dd>-<lesson-slug>.md`. Create one file per qualifying lesson. Use the date when the outcome became known and a short kebab-case slug that describes the lesson. If that path already exists, choose a more specific slug; never overwrite another lesson.

Record failed approaches and meaningful trial-and-error when their outcomes are known. Keep the failed entries even when a later approach succeeds. Record a `success` when the solution required substantial investigation or repeated attempts, or offers a reusable technique. Routine first-try successes and expected RED test failures do not require lesson entries.

Begin every lesson file with valid YAML frontmatter. Set `title` to a concise description, `date` to `yyyy-mm-dd`, `type` to exactly `failed` or `success`, `outdated` to a boolean, and `tags` to a YAML list of relevant problems, technologies, or conditions. Do not duplicate these fields in the Markdown body.

In the Markdown body, explain the context and goal, attempted approach, observed result and evidence, known cause or remaining uncertainty, and what to repeat or avoid under which conditions. For a hard-won success, link the earlier failed lesson files, explain how they led to the solution, and include reproducible verification. Preserve useful reasoning without copying terminal transcripts, secrets, or routine activity logs.

Create a lesson file only when there is a qualifying entry. Keep execution evidence in the active change as well; a lesson entry does not replace acceptance verification.

## Verify completion

Run fresh verification in the current turn.

Confirm all of these conditions:

- The current scope is approved and no unresolved clarification remains.
- Every acceptance scenario and preservation check passes.
- Every applicable boundary has a defined result.
- Every changed behavior has an automated test unless an approved exception covers it.
- The relevant tests pass.
- The project standard checks pass when the project defines them.
- The implementation does not add a stated non-goal.
- The observed behavior matches the approved change spec.

If any condition fails, stop the merge and keep the active change.

Do not report completion from old output, inference, or a prior conversation.

## Merge current behavior

Reread the active change and every affected spec file immediately before the merge.

Apply approved `modify` and `remove` operations when the affected current requirement still matches `Before` exactly except for insignificant formatting. An intentional replacement covered by the approved proposal does not require another approval.

If the target has changed since approval, a new ID now collides, or the change reveals an unapproved conflict, pause the affected merge. Resolve it within existing authorization where possible; ask only for a decision not already authorized. Preserve unrelated intervening changes.

Use [references/capability-spec.md](references/capability-spec.md) for approved additions whose spec file does not exist, at the standalone or grouped path listed in the proposal.

Merge by meaning, not by appending the whole change file.

Apply each `add`, `modify`, or `remove` to its identified spec file and requirement. For `add` and `modify`, merge the approved `After` sentence. For `remove`, remove only the approved requirement. Preserve IDs for retained requirements and update affected references.

Do not merge the change purpose, non-goals, user stories, Given-When-Then acceptance scenarios, boundary checks, or their local IDs into `docs/specs/`. Ensure every merged requirement is complete and testable without consulting the archived change. Represent any lasting boundary behavior as a requirement of its own.

When no requirement or spec content changes, as in a pure refactor, leave the canonical specs unchanged and review the preservation evidence before archiving the change.

Preserve unaffected current behavior.

Do not merge status, clarification markers, implementation notes, test commands, test output, or TDD evidence.

Review the merged specs against the verified behavior.

## Archive the completed change

After verification and merge review pass, finish any qualifying lesson entries and set the change spec to `Status: completed`. Move the exact `docs/changes/now/<change-slug>/` directory to `docs/changes/ended/<change-slug>/`; preserve the spec, evidence, and any supporting files.

Check the destination before moving and never overwrite an existing ended change. If it is occupied, keep the active change and resolve a distinct destination within the authorized scope. Keep blocked or unverified changes under `now/`.

Confirm the completed files exist at the destination and update affected document links to the ended path. Do not delete the change records after archiving.

Report the updated spec paths, fresh verification, ended change path, and any lesson files written.
