#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
article_dir="$repo_dir/content/posts/testing-low-level-macos-products"
article="$article_dir/index.md"

for image in \
  featured-image.png \
  virtual-machines.png \
  network-testing.png \
  recovery-mode.png \
  multiple-installations.png \
  multiple-devices.png \
  vnc.png \
  sleep-mode.png
do
  test -f "$article_dir/$image"
  grep -F "$image" "$article" >/dev/null
done

if find "$article_dir" -maxdepth 1 -type f -name '*capybara*' | grep . >/dev/null; then
  printf 'legacy capybara image names remain in %s\n' "$article_dir" >&2
  exit 1
fi

if grep -F 'capybara-' "$article" >/dev/null; then
  printf 'legacy capybara image reference remains in %s\n' "$article" >&2
  exit 1
fi
