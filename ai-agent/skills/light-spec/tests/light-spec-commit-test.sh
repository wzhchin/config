#!/usr/bin/env bash

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
commit_script=$script_dir/../scripts/light-spec-commit
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  [[ "$1" == "$2" ]] || fail "expected '$2', got '$1'"
}

commit_subject() {
  git -C "$project" cat-file -p HEAD | awk 'body { print; exit } /^$/ { body = 1 }'
}

project=$test_root/project
mkdir -p "$project/docs/changes/now" "$project/docs/changes/ended"
git -C "$project" init -q
git -C "$project" config user.name 'Light Spec Test'
git -C "$project" config user.email 'light-spec@example.invalid'
printf 'original\n' >"$project/README.md"
git -C "$project" add README.md
git -C "$project" commit -qm initial

change_dir=$project/docs/changes/now/2026-09-23-user-login
mkdir -p "$change_dir"
printf '# User login\n\nStatus: draft\n' >"$change_dir/proposal.md"
mkdir -p "$project/docs/changes/now/2026-09-24-user-login"
if (cd "$project" && "$commit_script" start user-login >/dev/null 2>&1); then
  fail 'start accepted an ambiguous slug'
fi
rmdir "$project/docs/changes/now/2026-09-24-user-login"
printf 'unrelated\n' >"$project/README.md"
git -C "$project" add README.md

(cd "$project" && "$commit_script" start user-login >/dev/null)
assert_eq "$(commit_subject)" 'spec: user-login(ul) start'
assert_eq "$(git -C "$project" diff --cached --name-only)" 'README.md'
git -C "$project" restore --staged README.md

if (cd "$project" && "$commit_script" start user-login >/dev/null 2>&1); then
  fail 'start accepted an unchanged proposal'
fi

printf 'work\n' >"$project/login.txt"
git -C "$project" add login.txt
(cd "$project" && "$commit_script" snapshot user-login 'add login flow' >/dev/null)
assert_eq "$(commit_subject)" 'ul: add login flow'

printf '# User login\n\nStatus: approved\n' >"$change_dir/proposal.md"
git -C "$project" add docs/changes/now/2026-09-23-user-login/proposal.md
(cd "$project" && "$commit_script" snapshot user-login >/dev/null)
assert_eq "$(commit_subject)" 'ul: snapshot'

if (cd "$project" && "$commit_script" snapshot user-login >/dev/null 2>&1); then
  fail 'snapshot accepted an empty index'
fi

if (cd "$project" && "$commit_script" end user-login >/dev/null 2>&1); then
  fail 'end accepted an incomplete proposal'
fi
[[ -d "$change_dir" ]] || fail 'failed end moved the active change'

printf '# User login\n\nStatus: completed\n' >"$change_dir/proposal.md"
mkdir -p "$project/docs/changes/ended/2026-09-23-user-login"
if (cd "$project" && "$commit_script" end user-login >/dev/null 2>&1); then
  fail 'end overwrote an existing archive destination'
fi
[[ -d "$change_dir" ]] || fail 'destination conflict moved the active change'
rmdir "$project/docs/changes/ended/2026-09-23-user-login"
git -C "$project" add README.md
(cd "$project" && "$commit_script" end user-login >/dev/null)
assert_eq "$(commit_subject)" 'spec: user-login finished'
[[ ! -e "$change_dir" ]] || fail 'active change still exists after end'
[[ -f "$project/docs/changes/ended/2026-09-23-user-login/proposal.md" ]] \
  || fail 'ended proposal is missing'
assert_eq "$(git -C "$project" diff --cached --name-only)" 'README.md'

project=$test_root/tracked-project
mkdir -p "$project/docs/changes/now/2026-09-23-profile-edit" "$project/docs/changes/ended"
git -C "$project" init -q
git -C "$project" config user.name 'Light Spec Test'
git -C "$project" config user.email 'light-spec@example.invalid'
printf 'Status: draft\n' >"$project/docs/changes/now/2026-09-23-profile-edit/proposal.md"
git -C "$project" add docs/changes/now/2026-09-23-profile-edit/proposal.md
git -C "$project" commit -qm initial
printf 'Status: approved\n' >"$project/docs/changes/now/2026-09-23-profile-edit/proposal.md"
(cd "$project" && "$commit_script" start profile-edit >/dev/null)
assert_eq "$(commit_subject)" 'spec: profile-edit(pe) start'

project=$test_root/new-project
mkdir -p "$project/docs/changes/now/2026-09-23-first-change" "$project/docs/changes/ended"
git -C "$project" init -q
git -C "$project" config user.name 'Light Spec Test'
git -C "$project" config user.email 'light-spec@example.invalid'
printf 'Status: draft\n' >"$project/docs/changes/now/2026-09-23-first-change/proposal.md"
(cd "$project" && "$commit_script" start first-change >/dev/null)
assert_eq "$(commit_subject)" 'spec: first-change(fc) start'

printf 'PASS: light-spec-commit\n'
