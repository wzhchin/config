# <Project> Constitution

This constitution defines the non-negotiable rules for changes that use Light Spec.

## Current behavior

- Treat `specs/<capability>/spec.md` as the source of truth for verified current behavior.
- Keep an active change in `changes/<change-slug>/spec.md`.
- Merge a change into `specs/` only after fresh verification passes.
- Delete the merged change.
- Do not create an archive.

## User value and scope

- Define one goal for each change.
- State explicit non-goals.
- Include at least one P1 user story.
- Make each user story independently implementable, testable, and demonstrable.
- Do not implement an unresolved `[NEEDS CLARIFICATION: ...]` item.

## Observable requirements

- Write each requirement as one observable behavior with exactly one `MUST`.
- Give every requirement at least one Given-When-Then scenario.
- Check applicable empty input, repeated action, permission, dependency failure, and state conflict boundaries.
- Keep implementation and architecture details out of requirements.

## Test-driven development

- Use TDD for every feature, defect fix, refactor, and behavior change.
- Write one failing behavior test before product code.
- Confirm that the test fails because the behavior is absent.
- Write only the product code required to pass the current test.
- Refactor only while the related tests pass.
- Complete one RED-GREEN-REFACTOR slice before starting the next behavior.
- For a defect, reproduce the defect with a failing test before fixing it.

## Completion

- Resolve every clarification.
- Pass every acceptance scenario and relevant test.
- Pass the project standard checks.
- Keep all stated non-goals out of the implementation.
- Make the canonical specs match the verified behavior.

## Exceptions

- Require explicit user approval for each TDD exception.
- Limit exceptions to throwaway prototypes, generated code, and pure configuration changes.
- Record the scope, reason, and reproducible alternative verification.
- Reject test difficulty and time pressure as exception reasons.

