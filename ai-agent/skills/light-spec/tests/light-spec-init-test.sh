#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
init_script="$script_dir/../scripts/light-spec-init.sh"
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_directory() {
  [[ -d "$1" ]] || fail "missing directory: $1"
}

assert_contains() {
  grep -Fq -- "$2" "$1" || fail "$1 does not contain: $2"
}

project="$test_root/project"
mkdir -p "$project/nested"
git -C "$project" init -q
printf '# Agent instructions\n' >"$project/AGENTS.md"
printf '# Claude instructions\n' >"$project/CLAUDE.md"
claude_before=$(cat -- "$project/CLAUDE.md")

"$init_script" "$project/nested"

for directory in \
  "$project/docs/specs" \
  "$project/docs/changes/now" \
  "$project/docs/changes/ended" \
  "$project/docs/lessons-learned"; do
  assert_directory "$directory"
done

assert_contains "$project/AGENTS.md" '<!-- light-spec:start -->'
assert_contains "$project/AGENTS.md" "Use the \`light-spec\` skill"
[[ "$(cat -- "$project/CLAUDE.md")" == "$claude_before" ]] || fail 'CLAUDE.md was modified'

"$init_script" "$project"

marker_count=$(grep -Fc -- '<!-- light-spec:start -->' "$project/AGENTS.md")
[[ "$marker_count" -eq 1 ]] || fail 'duplicate Light Spec prompt in AGENTS.md'
[[ "$(cat -- "$project/CLAUDE.md")" == "$claude_before" ]] || fail 'CLAUDE.md was modified'

plain_project="$test_root/plain-project"
mkdir -p "$plain_project"
"$init_script" "$plain_project"

assert_directory "$plain_project/docs/specs"
assert_directory "$plain_project/docs/changes/now"
assert_directory "$plain_project/docs/changes/ended"
assert_directory "$plain_project/docs/lessons-learned"
assert_contains "$plain_project/AGENTS.md" '<!-- light-spec:start -->'
assert_contains "$plain_project/AGENTS.md" "Use the \`light-spec\` skill"

"$init_script" "$plain_project"
marker_count=$(grep -Fc -- '<!-- light-spec:start -->' "$plain_project/AGENTS.md")
[[ "$marker_count" -eq 1 ]] || fail 'duplicate Light Spec prompt in created AGENTS.md'

cat >"$test_root/expected-agents.md" <<'EOF'
<!-- light-spec:start -->
## Light Spec

Use the `light-spec` skill to initialize or maintain project specifications, change records, and reusable lessons under `docs/`.
<!-- light-spec:end -->
EOF
cmp -s "$test_root/expected-agents.md" "$plain_project/AGENTS.md" \
  || fail 'created AGENTS.md content mismatch'
[[ ! -e "$plain_project/CLAUDE.md" ]] || fail 'CLAUDE.md was created'

printf 'PASS: light-spec-init.sh\n'
