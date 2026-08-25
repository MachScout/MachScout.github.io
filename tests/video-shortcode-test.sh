#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output_dir=$(mktemp -d)
trap 'rm -rf "$output_dir"' EXIT

hugo \
  --source "$repo_dir" \
  --contentDir "$repo_dir/tests/fixtures/video-shortcode/content" \
  --destination "$output_dir" \
  --quiet

rendered_page="$output_dir/posts/video/index.html"
rendered_video="$output_dir/posts/video/test-video.mp4"
rendered_poster="$output_dir/images/video-capybara.webp"

test -f "$rendered_page"
test -f "$rendered_video"
test -f "$rendered_poster"
grep -F '<figure class="video-card">' "$rendered_page" >/dev/null
grep -F '<video controls preload="metadata" playsinline width="16" height="9" poster="/images/video-capybara.webp">' "$rendered_page" >/dev/null
grep -F '<source src="/posts/video/test-video.mp4" type="video/mp4">' "$rendered_page" >/dev/null
grep -F '<figcaption>A short test clip.</figcaption>' "$rendered_page" >/dev/null
