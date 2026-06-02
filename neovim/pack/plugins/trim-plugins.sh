#!/bin/bash
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)/start"

KEEP_PATTERNS=(
    "lua"
    "plugin"
    "ftplugin"
    "data"
)

REMOVE_DIRS=(
    ".git"
    ".github"
    "doc"
    "tests"
    "spec"
    "scripts"
    "selene"
    "bin"
)

REMOVE_FILES=(
    .gitignore
    .editorconfig
    .luacheckrc
    .luarc.json
    .lua-format
    .markdownlint-cli2.yaml
    .neoconf.json
    .rubocop.yml
    .ruby-version
    .stylua.toml
    .styluaignore
    .typos.toml
    Gemfile
    Gemfile.lock
    LICENSE
    Makefile
    NEWS.md
    POPUP.md
    README.md
    TESTS_README.md
    TODO.md
    USAGE.md
    CHANGELOG.md
    CONTRIBUTING.md
    developers.md
    lefthook.yml
    notes
    recipes.json
    rockspec.template
    selene.toml
    vim.yml
)

for plugin in "$PLUGIN_DIR"/*/; do
    git rm --cached "$plugin" -f
    plugin_name="$(basename "$plugin")"
    echo "==> Trimming: $plugin_name"

    git_dir="$plugin.git"
    if [ -d "$git_dir" ]; then
        remote_url="$(git -C "$plugin" remote get-url origin 2>/dev/null || echo "unknown")"
        commit_id="$(git -C "$plugin" rev-parse HEAD 2>/dev/null || echo "unknown")"
        echo "    remote: $remote_url"
        echo "    commit: $commit_id"
        printf '%s\n' "$remote_url" "$commit_id" > "$plugin.git-version"
        rm -rf "$git_dir"
    fi

    for d in "${REMOVE_DIRS[@]}"; do
        target="$plugin$d"
        if [ -e "$target" ]; then
            echo "    rm -rf $d/"
            rm -rf "$target"
        fi
    done

    for f in "${REMOVE_FILES[@]}"; do
        target="$plugin$f"
        if [ -e "$target" ]; then
            echo "    rm $f"
            rm "$target"
        fi
    done

    find "$plugin" -maxdepth 1 \( -name '*.rockspec' -o -name 'stylua.toml' -o -name '.stylua.toml' \) -type f -exec rm -v {} \;

    echo "    done."
    echo
done

echo "==> Trim complete."
echo
echo "Remaining structure:"
find "$PLUGIN_DIR" -type f | sed "s|$PLUGIN_DIR/||" | sort
