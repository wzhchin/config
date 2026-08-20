---
name: sync-do
description: >
  Push the current tree to an existing SSH host with rsync, then run a
  stdin bash script there via sync-do. Use when the user says sync-do,
  ssh-remote, remote compile, 远程编译, rsync+ssh, local agent remote
  build, or /sync-do.
---

# sync-do

Local agent edits source. Remote host compiles and tests. Do not move the
agent onto the box. Do not rent a sandbox.

Tool: this skill's `scripts/sync-do`. `$CHIN_CONFIG_DIR/scripts/sync-do` is a symlink to it (on PATH as `sync-do`).

## Invoke

Cwd must be the project root.

```bash
sync-do [--workdir /remote/path] <<'EOF'
make -j"$(nproc)"
EOF
```

Stdin is required. Empty stdin still syncs, then runs no user commands.

## Project config

File: `./.ssh-remote.sh` (sourced as bash). Do not commit it.

```bash
host=buildbox
workdir=~/builds/myproj
excludes=(
    target
    .gradle
)
```

| Name | Required | Meaning |
|---|---|---|
| `host` | yes | SSH `Host` alias or `user@hostname`. Port stays in `~/.ssh/config`. |
| `workdir` | yes unless `--workdir` | Remote directory. Relative = remote home. |
| `excludes` | no | Extra rsync `--exclude` entries. Use for artifact dirs missing from `.gitignore`. |

`--workdir` overrides `workdir` for one run. No flag overrides `host`.

If the file is missing, ask for `host` and `workdir`, write the file, and add `.ssh-remote.sh` to `.gitignore` as a deliberate project edit. Do not append `.gitignore` as a runtime side effect of `sync-do`.

## Rsync contract

`sync-do` must use exactly this shape:

```bash
rsync -a \
    --delete \
    --delete-after \
    --exclude .git \
    --exclude .ssh-remote.sh \
    --filter=':- .gitignore' \
    "${exclude_args[@]}" \
    ./ \
    "${host}:${workdir}/"
```

`exclude_args` is one `--exclude` per `excludes` entry. An empty array is fine.

- `--delete` removes remote files that local deleted. Stale source must not stay.
- `--delete-after` waits until `.gitignore` is on the remote, then deletes. Default `--delete-during` uses stale remote rules.
- `--filter=':- .gitignore'` drops those paths from the send list and protects them from delete. That is how gitignored `target/` / `node_modules/` survive.
- Do not add `--delete-excluded`. It deletes the protected artifact trees.
- Do not hardcode `target`, `build`, `out`, or `node_modules` in the script. Those names are also source directories. Declare them in `.gitignore` or `excludes`.
- `:- .gitignore` is rsync exclude-line syntax, not git's parser. `target/` and `*.o` work. Do not rely on `!` un-ignore matching git.
- A local empty artifact dir that is not ignored still wipes the remote tree under `--delete`. Put that dir in `.gitignore` or `excludes`.
- `sync` is not `clean`. Wipe a remote cache with an explicit remote command.
- `host:22` is invalid. Port belongs in SSH config. A colon in `host` breaks rsync dest syntax.

Connection reuse belongs in `~/.ssh/config` (`ControlMaster`), not in `sync-do`.

## Remote script

Pipe to `ssh -- "$host" bash`. First lines:

```bash
set -euo pipefail
workdir=<printf %q of workdir>
cd "$workdir"
```

Then the user body. `cd` failure must abort. Do not run the body in the remote home.

No TTY (`-t`) unless the user asks for an interactive remote program.

## When editing the script

Edit only this skill's `scripts/sync-do`. Keep `$CHIN_CONFIG_DIR/scripts/sync-do` as a symlink to that file. Load `shell-script-style` first.

Do not invent a second wrapper. Do not add a Makefile `remote-build` unless the user asks.

## Agent checklist

1. `command -v sync-do`; `ssh` and `rsync` on PATH.
2. Cwd is the project root. `.ssh-remote.sh` has non-empty `host` and `workdir`.
3. Artifact dirs are in `.gitignore` or `excludes`. If not, say so before the first `--delete` run.
4. Run `sync-do` with the project's compile/test command on stdin. Capture full stdout/stderr.
5. Do not compile locally unless the user asks.
