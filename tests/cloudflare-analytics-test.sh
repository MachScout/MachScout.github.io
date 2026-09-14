#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
production_output=$(mktemp -d)
development_output=$(mktemp -d)
trap 'rm -rf "$production_output" "$development_output"' EXIT

hugo --source "$repo_dir" \
  --contentDir "$repo_dir/tests/fixtures/theme-site/content" \
  --destination "$production_output" \
  --baseURL "https://example.test/" \
  --environment production \
  --quiet

hugo --source "$repo_dir" \
  --contentDir "$repo_dir/tests/fixtures/theme-site/content" \
  --destination "$development_output" \
  --baseURL "https://example.test/" \
  --environment development \
  --quiet

production_page="$production_output/index.html"
development_page="$development_output/index.html"
beacon_url='https://static.cloudflareinsights.com/beacon.min.js'
site_token='c72b032b69c84f628dd95a83bde82558'

beacon_count=$(grep -oF "$beacon_url" "$production_page" | wc -l | tr -d ' ')
if [ "$beacon_count" -ne 1 ]; then
  printf 'expected one Cloudflare beacon in production HTML, found %s\n' "$beacon_count" >&2
  exit 1
fi

grep -F "$site_token" "$production_page" >/dev/null

if grep -F "$beacon_url" "$development_page" >/dev/null; then
  printf 'Cloudflare beacon must not be present in development HTML\n' >&2
  exit 1
fi
