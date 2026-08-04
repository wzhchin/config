---
name: python-must-read
description: >
  Must-read Python conventions for environment and dependency management.
  Apply whenever writing, editing, or reviewing Python code or scripts.
  Triggers: python, .py, venv, uv, dependencies, scripts.
---

# Python Must-Read

Create Python virtual environments with `uv` (`.venv`) and add `.venv/` to `.gitignore`.

When a Python script needs external dependencies, prefer a **uv script** (file header `# /// script` + `dependencies`) so uv installs them automatically—do not hand-roll venv + pip for one-off scripts.
