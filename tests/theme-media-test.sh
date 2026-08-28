#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"

output_dir=$(build_fixture theme-site)
failure_dir=$(mktemp -d)
trap 'rm -rf "$output_dir" "$failure_dir"' EXIT

page="$output_dir/posts/local-article/index.html"
raster_page="$output_dir/posts/raster-article/index.html"
stylesheet=$(find "$output_dir/css" -name '*.css' -type f | head -n 1)

assert_contains "$page" 'class="media-figure theme-aware-diagram"'
assert_contains "$page" 'alt="Fixture diagram"'
assert_contains "$page" '<figcaption>Diagram caption.</figcaption>'
assert_contains "$page" 'poster="/posts/local-article/poster.svg"'
assert_contains "$page" 'style="--media-ratio: 4/3; --media-max-width: 36rem;"'
assert_contains "$page" 'preload="metadata"'
assert_contains "$page" 'playsinline'
assert_contains "$page" 'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ'
assert_contains "$page" 'title="Fixture YouTube video"'
assert_contains "$page" 'loading="lazy"'
assert_contains "$page" 'referrerpolicy="strict-origin-when-cross-origin"'
assert_contains "$raster_page" 'class="media-frame media-frame--png"'
assert_contains "$raster_page" 'width="1200" height="675" alt="Fixture raster photograph"'
assert_contains "$raster_page" 'sizes="(min-width: 50rem) 48rem, calc(100vw - 2rem)"'
assert_contains "$stylesheet" '.article__content>.media-figure,.article__content>.video-card{width:min(100%,var(--media-max-width,100%))'
assert_contains "$stylesheet" '.video-card>video{height:auto}'
assert_not_contains "$stylesheet" 'margin-left:-8rem'
assert_not_contains "$stylesheet" 'max-width:none;margin-left:-8rem'

assert_build_fails() {
  fixture=$1
  shortcode=$2
  log_file="$failure_dir/$fixture.log"
  destination="$failure_dir/$fixture"

  if hugo --source "$repo_dir" \
    --contentDir "$repo_dir/tests/fixtures/$fixture/content" \
    --destination "$destination" \
    --baseURL "https://example.test/" >"$log_file" 2>&1; then
    printf 'expected Hugo build to fail for %s\n' "$fixture" >&2
    exit 1
  fi

  assert_contains "$log_file" "$shortcode shortcode"
  assert_contains "$log_file" 'posts/bad/index.md'
}

assert_build_fails invalid-media-image image
assert_build_fails invalid-media-image-alt image
assert_build_fails invalid-media-video video
assert_build_fails invalid-media-video-poster video
assert_build_fails invalid-media-youtube-id youtube
assert_build_fails invalid-media-youtube-title youtube
assert_build_fails invalid-media-video-ratio video
assert_build_fails invalid-media-video-width video
