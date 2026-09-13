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
assert_contains "$page" '<a class="media-lightbox__trigger" href="/posts/local-article/media.svg" data-lightbox-trigger data-lightbox-src="/posts/local-article/media.svg"'
assert_contains "$page" 'aria-label="Open Fixture diagram fullscreen"'
assert_contains "$page" 'class="media-carousel" data-carousel aria-label="Fixture gallery"'
assert_contains "$page" 'aria-roledescription="carousel">'
assert_not_contains "$page" 'aria-roledescription="carousel" tabindex="0"'
assert_contains "$page" 'class="media-carousel__slide" data-carousel-slide'
assert_not_contains "$page" 'aria-hidden="true" hidden'
assert_contains "$page" 'class="media-carousel__controls" hidden'
assert_contains "$page" 'data-carousel-previous aria-label="Previous image"'
assert_contains "$page" 'data-carousel-next aria-label="Next image"'
assert_contains "$page" 'data-carousel-current>1</span> / <span data-carousel-total>2</span>'
assert_contains "$page" '<figcaption class="media-carousel__caption">Gallery caption.</figcaption>'
assert_contains "$page" 'class="media-lightbox" data-lightbox aria-label="Fullscreen image"'
assert_contains "$page" 'data-lightbox-close aria-label="Close fullscreen image"'
assert_contains "$page" 'icon icon--close'
assert_contains "$page" 'data-lightbox-controls hidden'
assert_contains "$page" 'data-lightbox-previous aria-label="Previous image"'
assert_contains "$page" 'data-lightbox-next aria-label="Next image"'
assert_contains "$page" 'data-lightbox-current>1</span> / <span data-lightbox-total>1</span>'
assert_contains "$page" 'icon icon--chevron-left'
assert_contains "$page" 'icon icon--chevron-right'
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
assert_contains "$stylesheet" '.media-carousel__slide[hidden]{display:none}'
assert_contains "$stylesheet" '.media-carousel__slide .media-lightbox__trigger{width:min(100%,96vh,58.6667rem);aspect-ratio:4/3;margin-inline:auto}'
assert_contains "$stylesheet" '.media-carousel__slide .media-frame{width:100%;height:100%;border:0;border-radius:0;object-fit:contain}'
assert_contains "$stylesheet" '.media-lightbox[open]'
assert_contains "$stylesheet" '.media-lightbox__controls[hidden]{display:none}'
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
