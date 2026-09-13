#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"

output_dir=$(build_fixture theme-site)
trap 'rm -rf "$output_dir"' EXIT

page="$output_dir/posts/local-article/index.html"
hidden_page="$output_dir/posts/hidden-featured/index.html"
home="$output_dir/index.html"
external_page="$output_dir/posts/external-article/index.html"
empty_toc_page="$output_dir/posts/toc-without-headings/index.html"
set -- "$output_dir"/css/site*.css
stylesheet=$1
set -- "$output_dir"/js/site*.js
javascript=$1

assert_contains "$page" '<main id="main-content" class="main-content--article"'
assert_contains "$page" '<article class="article article--with-toc">'
assert_contains "$page" 'class="article-hero"'
assert_contains "$page" 'alt="Local fixture featured image"'
assert_not_contains "$page" '<p class="article__description">'
assert_contains "$page" 'fetchpriority="high"'
assert_contains "$page" '<div class="article__layout">'
assert_contains "$page" '<div class="article__body">'
assert_contains "$page" '<details class="table-of-contents" aria-labelledby="table-of-contents-title" data-toc open>'
layout_line=$(grep -n '<div class="article__layout">' "$page" | head -n 1 | cut -d: -f1)
header_line=$(grep -n '<header class="article__header">' "$page" | head -n 1 | cut -d: -f1)
if test "$layout_line" -ge "$header_line"; then
  printf 'desktop article layout must include the header so the table of contents can align with it\n' >&2
  exit 1
fi
assert_contains "$page" '<summary class="table-of-contents__summary">'
assert_contains "$page" '<span id="table-of-contents-title">Contents</span>'
assert_contains "$page" '<div class="table-of-contents__content">'
assert_not_contains "$page" '<a href="#level-one">Level one</a>'
assert_contains "$page" 'href="#level-two"'
assert_contains "$page" '<h1 id="level-one"'
assert_contains "$page" '<h5 id="level-five"'
assert_contains "$page" 'href="#comappledeveloperendpointsecurityclientauthorizationmonitoringextension"'
assert_contains "$page" 'class="heading-anchor"'
assert_contains "$page" 'aria-label="Link to Level five"'
assert_contains "$page" '<div class="table-scroll">'
assert_contains "$page" '<th>Column one</th>'
assert_contains "$page" '<td>Value</td>'
assert_contains "$page" 'Reading time'
assert_contains "$page" 'class="icon icon--calendar"'
assert_contains "$page" 'class="icon icon--clock"'
assert_contains "$page" 'class="icon icon--tag"'
assert_contains "$page" 'class="icon icon--folder"'
assert_not_contains "$hidden_page" 'article-hero'
assert_contains "$home" '/posts/hidden-featured/featured-image.svg'
assert_contains "$external_page" '<link rel="canonical" href="https://outside.example/articles/hugo">'
assert_contains "$external_page" '<meta name="robots" content="noindex,follow">'
assert_not_contains "$external_page" '<main id="main-content" class="main-content--article"'
assert_contains "$external_page" 'Read the original article'
assert_not_contains "$external_page" 'EXTERNAL-BODY-MUST-NOT-RENDER'
assert_contains "$page" '<a class="article-adjacent__previous" href="/posts/hidden-featured/">← Hidden featured fixture article</a>'
assert_contains "$page" '<a class="article-adjacent__next" href="/posts/raster-article/">Raster fixture article →</a>'
assert_not_contains "$page" 'href="/posts/external-article/"'
assert_not_contains "$page" 'External article'
assert_not_contains "$empty_toc_page" 'class="table-of-contents"'
assert_file "$stylesheet"
assert_file "$javascript"
assert_contains "$javascript" 'aria-current'
if ! grep -F '.article-featured--hero{border-radius:.4rem}' "$stylesheet" >/dev/null; then
  printf 'article hero images must preserve their intrinsic aspect ratio\n' >&2
  exit 1
fi
grep -E '\.article__content h4\{[^}]*font-size:1\.3rem;[^}]*font-weight:700' "$stylesheet" >/dev/null
grep -E '\.article__content h5\{[^}]*color:var\(--color-muted\);[^}]*font-size:1\.05rem;[^}]*font-weight:600' "$stylesheet" >/dev/null
grep -E '@media[[:space:]]*\(min-width:86rem\)\{[^}]*#main-content\.main-content--article\{[^}]*width:min\(calc\(100% - 2rem\),84rem\)' "$stylesheet" >/dev/null
grep -E '\.article__layout\{[^}]*grid-template-columns:16rem[[:space:]]*minmax\(0,var\(--content-width\)\)[[:space:]]*16rem' "$stylesheet" >/dev/null
grep -E '\.article__body\{[^}]*grid-column:2' "$stylesheet" >/dev/null
grep -E '\.table-of-contents\{[^}]*position:sticky;[^}]*top:5\.5rem' "$stylesheet" >/dev/null
grep -E '\.table-of-contents a\{[^}]*overflow-wrap:anywhere' "$stylesheet" >/dev/null
grep -E '\.table-of-contents\{[^}]*font-size:\.8125rem' "$stylesheet" >/dev/null
grep -E '@media\(min-width:86rem\)\{.*\.table-of-contents nav>ul ul\{display:none' "$stylesheet" >/dev/null
grep -E '@media\(min-width:86rem\)\{.*\.table-of-contents li\[data-toc-active\]>ul\{display:block' "$stylesheet" >/dev/null
