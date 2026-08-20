---
name: light-spec
description: Run a lightweight specification-to-TDD workflow with an approval gate, temporary change specs, observable requirements, user stories, Given-When-Then scenarios, vertical RED-GREEN-REFACTOR slices, fresh verification, and semantic merge into canonical specs. Use only when the user explicitly asks to use the `light-spec` skill. 
---

# Light Spec

Turn one approved behavior change into tested code and current specifications.

Keep `specs/` as the source of truth for verified current behavior.

Keep the active change in `changes/<change-slug>/spec.md`.

Do not create an archive.

## Preserve the approval gate

Inspect the target repository and its local instructions before proposing files.

Read `constitution.md` when it exists.

Read every affected `specs/<capability>/spec.md` when it exists.

If `constitution.md` does not exist, adapt [assets/constitution.md](assets/constitution.md) to the project and include it in the proposal.

Discuss the goal, non-goals, user value, affected capability, boundaries, and public behavior with the user.

Ask one blocking question at a time.

Mark unresolved high-impact information as `[NEEDS CLARIFICATION: <question>]`.

Do not create or modify files before the user approves the complete draft in the conversation.

Do not treat silence, partial agreement, or approval of one section as approval of the complete draft.

If the user changes the draft, revise it and request approval again.

Do not start implementation while a clarification marker remains.

## Draft one change

Use [assets/change-spec.md](assets/change-spec.md) as the change format.

Use a short kebab-case change slug.

Use a short kebab-case capability name for each affected area.

Define one change goal.

State explicit non-goals.

Write at least one P1 user story.

Make each user story independently implementable, testable, and demonstrable.

Write each requirement as one observable behavior with exactly one `MUST`.

Give every requirement at least one concrete Given-When-Then scenario.

Check these boundary categories and include each applicable case:

- Empty or missing input.
- Repeated action or idempotency.
- Permission or ownership.
- Dependency failure.
- Conflict with existing state or behavior.

Do not invent a high-impact product, security, compatibility, or data decision.

Do not put implementation details, architecture, task lists, or terminal transcripts in a requirement.

After approval, create `changes/<change-slug>/spec.md` without overwriting another active change.

Create the approved `constitution.md` only when it is missing.

## Implement one vertical slice

Select the highest-priority unfinished scenario.

Execute one RED-GREEN-REFACTOR slice before starting the next scenario.

### RED

Write one minimal automated test for one observable behavior.

Test through a public interface.

Mock only an external system boundary when real integration is impractical.

Run the narrow test.

Confirm that it fails because the specified behavior is absent.

If the test passes immediately, correct the test or confirm that the behavior already exists.

If the test errors for an unrelated reason, fix the test setup and rerun it.

For a defect, make the test reproduce the defect before changing product code.

### GREEN

Write only the product code required to pass the current test.

Do not add behavior for later scenarios.

Run the narrow test.

Run the related test set.

### REFACTOR

Refactor only while all related tests pass.

Remove duplication or improve structure and names without adding behavior.

Rerun the related test set after each refactor step.

Record concise RED, GREEN, and REFACTOR evidence in the active change spec.

Repeat the cycle for the next scenario.

## Control TDD exceptions

Allow a TDD exception only for a throwaway prototype, generated code, or a pure configuration change.

Require explicit user approval for the exception.

Record its scope, reason, and reproducible alternative verification in the active change spec.

Reject “testing is difficult” and “time is short” as exception reasons.

## Verify completion

Run fresh verification in the current turn.

Confirm all of these conditions:

- No clarification marker remains.
- Every requirement has a passing scenario.
- Every applicable boundary has a defined result.
- Every changed behavior has an automated test unless an approved exception covers it.
- The relevant tests pass.
- The project standard checks pass when the project defines them.
- The implementation does not add a stated non-goal.
- The observed behavior matches the approved change spec.

If any condition fails, stop the merge and keep the active change.

Do not report completion from old output, inference, or a prior conversation.

## Merge current behavior

Reread the active change and every affected capability spec immediately before the merge.

Stop and ask the user when the change conflicts with an existing requirement.

Use [assets/capability-spec.md](assets/capability-spec.md) when a capability spec does not exist.

Merge by meaning, not by appending the whole change file.

Add or update the approved user value, user stories, observable requirements, scenarios, applicable boundaries, and non-goals.

Preserve unaffected current behavior.

Do not merge status, clarification markers, implementation notes, test commands, test output, or TDD evidence.

Review the merged capability specs against the verified behavior.

Delete only the exact approved `changes/<change-slug>/` directory after the merge review passes.

Do not create or move the change into an archive.

Report the updated capability specs, fresh verification, and deleted change path.

