repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

build_fixture() {
  fixture=$1
  destination=$(mktemp -d)
  hugo --source "$repo_dir" \
    --contentDir "$repo_dir/tests/fixtures/$fixture/content" \
    --destination "$destination" \
    --baseURL "https://example.test/" --quiet
  printf '%s\n' "$destination"
}

assert_file() { test -f "$1" || { printf 'missing file: %s\n' "$1" >&2; exit 1; }; }
assert_contains() { grep -F "$2" "$1" >/dev/null || { printf 'missing %s in %s\n' "$2" "$1" >&2; exit 1; }; }
assert_not_contains() { if grep -F "$2" "$1" >/dev/null; then printf 'unexpected %s in %s\n' "$2" "$1" >&2; exit 1; fi; }
