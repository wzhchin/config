# Frontend Rules

Keep the existing stack and package manager unless the user requests a migration.

Use plain HTML for one static or lightly interactive page.

Keep the page in one file when it needs no reusable modules or build step.

If it needs reusable modules, ask before splitting HTML and JavaScript.

Prefer `pnpm` over npm or Yarn when dependency management is required.

For a new multi-page application, prefer React, Vite, and Tailwind CSS.
