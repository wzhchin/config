---
name: frontend-must-read
description: >
  Must-read frontend conventions for stack choice and tooling.
  Apply whenever building web pages, UI, or frontend apps.
  Triggers: html, frontend, webpage, react, vite, tailwind, pnpm, css, js.
---

# Frontend Must-Read

For simple web pages, use plain HTML (no framework).

- If the page is small enough, keep everything in a single HTML file.
- If it gets more complex, ask the user whether to split HTML and JS into separate files.

When dependency management is needed, prefer **pnpm** over npm/yarn.

For more complex web apps, prefer **React + Vite + Tailwind CSS**.
