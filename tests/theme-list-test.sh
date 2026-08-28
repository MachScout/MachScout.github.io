#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"

output_dir=$(build_fixture theme-site)
invalid_dir=$(mktemp -d)
invalid_log=$(mktemp)
trap 'rm -rf "$output_dir" "$invalid_dir" "$invalid_log"' EXIT

card_for_title() {
  awk -v card_title="$2" '
    /<article class="article-card/ { capturing = 1; card = "" }
    capturing { card = card $0 ORS }
    capturing && /<\/article>/ {
      if (index(card, card_title)) { printf "%s", card; exit }
      capturing = 0
      card = ""
    }
  ' "$1"
}

assert_card_contains() {
  if ! card_for_title "$1" "$2" | grep -F -- "$3" >/dev/null; then
    printf 'missing %s in %s card\n' "$3" "$2" >&2
    exit 1
  fi
}

assert_card_not_contains() {
  assert_card_contains "$1" "$2" "$2"
  if card_for_title "$1" "$2" | grep -F -- "$3" >/dev/null; then
    printf 'unexpected %s in %s card\n' "$3" "$2" >&2
    exit 1
  fi
}

assert_invalid_external() {
  fixture=$1
  invalid_url=$2
  if hugo --source "$repo_dir" \
    --contentDir "$repo_dir/tests/fixtures/$fixture/content" \
    --destination "$invalid_dir" --baseURL "https://example.test/" >"$invalid_log" 2>&1; then
    printf 'invalid externalURL fixture unexpectedly built: %s\n' "$fixture" >&2
    exit 1
  fi
  assert_contains "$invalid_log" 'externalURL must be an absolute http(s) URL'
  assert_contains "$invalid_log" "$invalid_url"
}

home="$output_dir/index.html"
posts="$output_dir/posts/index.html"
page_two="$output_dir/page/2/index.html"
stylesheet=$(find "$output_dir/css" -name '*.css' -type f | head -n 1)
assert_file "$posts"
assert_file "$page_two"
assert_contains "$home" 'class="article-card article-card--external"'
assert_contains "$home" 'href="https://outside.example/articles/hugo"'
assert_contains "$home" 'target="_blank"'
assert_contains "$home" 'rel="external noopener noreferrer"'
assert_contains "$home" 'outside.example'
assert_contains "$home" 'External article'
assert_contains "$home" 'href="/posts/local-article/"'
assert_contains "$home" 'class="article-card__byline"'
assert_contains "$home" 'published on'
assert_contains "$home" 'included in'
assert_contains "$home" 'class="article-card__read-more"'
assert_contains "$home" '>Read More</a>'
assert_contains "$home" 'class="article-card__footer"'
assert_contains "$home" 'loading="lazy"'
assert_contains "$home" 'featured-image.svg'
assert_not_contains "$home" 'article-card__placeholder'
assert_contains "$posts" 'Local fixture article'
assert_contains "$home" 'class="pagination__next" href="/page/2/"'
assert_not_contains "$home" 'class="pagination__previous"'
assert_contains "$page_two" 'class="pagination__previous" href="/"'
assert_not_contains "$page_two" 'class="pagination__next"'
assert_contains "$page_two" 'Text-only fixture article'

assert_card_contains "$home" 'External article' 'class="article-card__image-link" href="https://outside.example/articles/hugo" target="_blank" rel="external noopener noreferrer" aria-hidden="true" tabindex="-1"'
assert_card_contains "$home" 'External article' 'class="article-card__primary-link" href="https://outside.example/articles/hugo" target="_blank" rel="external noopener noreferrer"'
assert_card_contains "$home" 'External article' 'class="article-card__read-more" href="https://outside.example/articles/hugo" target="_blank" rel="external noopener noreferrer" aria-label="Read More: External article"'
assert_card_contains "$home" 'External article' 'href="/tags/external-tag/"'
assert_card_contains "$home" 'External article' 'href="/categories/external-category/"'
assert_card_not_contains "$home" 'External article' 'href="/tags/external-tag/" tabindex="-1"'
assert_card_contains "$home" 'Local fixture article' 'alt=""'
assert_contains "$stylesheet" '.article-card__primary-link{position:absolute;inset:0;z-index:1'
assert_contains "$stylesheet" '.article-card__taxonomies{position:relative;z-index:2'
assert_contains "$stylesheet" '.article-card{position:relative;display:block'
assert_contains "$stylesheet" '.article-featured--card{aspect-ratio:3/1'
assert_contains "$stylesheet" '.article-featured--card{aspect-ratio:16/9}'
assert_contains "$stylesheet" '.article-featured{width:100%;height:auto;background:var(--color-surface);object-fit:cover}'
assert_contains "$stylesheet" '@media(prefers-reduced-motion:no-preference){.article-featured{transition:transform 160ms ease}.article-card__image-link:hover .article-featured{transform:scale(1.02)}'

assert_card_contains "$page_two" 'Text-only fixture article' 'class="article-card article-card--text-only"'
assert_card_not_contains "$page_two" 'Text-only fixture article' 'article-card__image-link'

assert_card_contains "$home" 'Raster fixture article' 'src="/posts/raster-article/raster-cover.png"'
assert_card_contains "$home" 'Raster fixture article' '.png 480w'
assert_card_contains "$home" 'Raster fixture article' '.png 960w'
assert_card_contains "$home" 'Raster fixture article' 'raster-cover.png 1200w'
assert_card_contains "$home" 'Raster fixture article' 'sizes="(min-width: 74rem) 72rem, calc(100vw - 2rem)"'
assert_card_contains "$home" 'Raster fixture article' 'width="1200" height="675"'

assert_invalid_external invalid-external '/relative'
assert_invalid_external invalid-external-no-host 'https://'
assert_invalid_external invalid-external-path-only 'https:///path'
assert_invalid_external invalid-external-query-only 'https://?query'
