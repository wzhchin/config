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

"$init_script" "$project/nested"

for directory in \
  "$project/docs/specs" \
  "$project/docs/changes/now" \
  "$project/docs/changes/ended" \
  "$project/docs/lessons-learned"; do
  assert_directory "$directory"
done

for instructions_file in "$project/AGENTS.md" "$project/CLAUDE.md"; do
  assert_contains "$instructions_file" '<!-- light-spec:start -->'
  assert_contains "$instructions_file" "Use the \`light-spec\` skill"
done

"$init_script" "$project"

for instructions_file in "$project/AGENTS.md" "$project/CLAUDE.md"; do
  marker_count=$(grep -Fc -- '<!-- light-spec:start -->' "$instructions_file")
  [[ "$marker_count" -eq 1 ]] || fail "duplicate Light Spec prompt in $instructions_file"
done

plain_project="$test_root/plain-project"
mkdir -p "$plain_project"
"$init_script" "$plain_project"

assert_directory "$plain_project/docs/specs"
assert_directory "$plain_project/docs/changes/now"
assert_directory "$plain_project/docs/changes/ended"
assert_directory "$plain_project/docs/lessons-learned"
[[ ! -e "$plain_project/AGENTS.md" ]] || fail 'AGENTS.md should not be created'
[[ ! -e "$plain_project/CLAUDE.md" ]] || fail 'CLAUDE.md should not be created'

printf 'PASS: light-spec-init.sh\n'
