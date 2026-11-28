SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cd "$SCRIPT_DIR"

git status --porcelain=v1 | awk '{print $2}' | sed 's|/.*||g' | sort -u | xargs -I % sh -c 'git add % && git commit -m "%: update"'
