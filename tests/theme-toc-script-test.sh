#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
node_bin=$(command -v node || true)
if test -z "$node_bin"; then
  node_bin="$HOME/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node"
fi
test -x "$node_bin"
"$node_bin" "$repo_dir/tests/theme-toc-script-test.js" "$repo_dir/assets/js/toc.js"
