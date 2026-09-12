# Python Rules

Create Python virtual environments with `uv` in `.venv`.

If the project uses Git, ensure that its ignore rules cover `.venv/`.

Use a uv script for a one-off script that needs external dependencies.

Declare dependencies in the PEP 723 `# /// script` metadata block.

Do not create a manual venv and pip workflow for a one-off script.
