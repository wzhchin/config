#!/usr/bin/env bash

set -euo pipefail

if (( $# > 1 )); then
  printf 'Usage: %s [project-directory]\n' "$(basename -- "$0")" >&2
  exit 2
fi

project_path=${1:-.}

if [[ ! -d "$project_path" ]]; then
  printf 'Project directory does not exist: %s\n' "$project_path" >&2
  exit 1
fi

project_path=$(cd -- "$project_path" && pwd -P)

if command -v git >/dev/null 2>&1 \
  && project_root=$(git -C "$project_path" rev-parse --show-toplevel 2>/dev/null); then
  :
else
  project_root=$project_path
fi

mkdir -p \
  "$project_root/docs/specs" \
  "$project_root/docs/changes/now" \
  "$project_root/docs/changes/ended" \
  "$project_root/docs/lessons-learned"

prompt_marker='<!-- light-spec:start -->'
prompt=$(cat <<'EOF'
<!-- light-spec:start -->
## Light Spec

Use the `light-spec` skill to initialize or maintain project specifications, change records, and reusable lessons under `docs/`.
<!-- light-spec:end -->
EOF
)

updated_count=0

for instructions_name in AGENTS.md CLAUDE.md; do
  instructions_file="$project_root/$instructions_name"
  [[ -f "$instructions_file" ]] || continue

  if grep -Fq -- "$prompt_marker" "$instructions_file"; then
    continue
  fi

  if [[ -s "$instructions_file" ]]; then
    printf '\n' >>"$instructions_file"
  fi
  printf '%s\n' "$prompt" >>"$instructions_file"
  printf 'Updated %s\n' "$instructions_file"
  ((updated_count += 1))
done

printf 'Initialized Light Spec directories under %s/docs\n' "$project_root"

if (( updated_count == 0 )); then
  printf 'No root AGENTS.md or CLAUDE.md required an update.\n'
fi
