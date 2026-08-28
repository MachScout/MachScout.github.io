#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"

output_dir=$(build_fixture theme-site)
instagram_output_dir=$(mktemp -d)
metadata_output_dir=$(mktemp -d)
trap 'rm -rf "$output_dir" "$instagram_output_dir" "$metadata_output_dir"' EXIT

build_metadata_fixture() {
  hugo --source "$repo_dir" \
    --contentDir "$repo_dir/tests/fixtures/metadata-fallback/content" \
    --destination "$metadata_output_dir" \
    --baseURL "https://example.test/" \
    --quiet
}

build_instagram_fixture() {
  hugo --source "$repo_dir" \
    --contentDir "$repo_dir/tests/fixtures/instagram-shortcode/content" \
    --destination "$instagram_output_dir" \
    --baseURL "https://example.test/" \
    --quiet
}

if [ "${THEME_DISCOVERY_FOCUS:-}" = "metadata" ]; then
  build_metadata_fixture
  assert_contains "$metadata_output_dir/posts/metadata-less/index.html" '<meta name="description" content="Notes on Apple platforms, macOS internals, smart homes, electronics, and engineering practice by Dmytro Hladkyi.">'
  assert_not_contains "$metadata_output_dir/posts/metadata-less/index.html" '<meta name="description" content="BODY-CONTENT-MUST-NOT-BECOME-METADATA">'
  exit 0
fi

if [ "${THEME_DISCOVERY_FOCUS:-}" = "instagram" ]; then
  build_instagram_fixture
  assert_contains "$instagram_output_dir/posts/instagram/index.html" 'class="instagram-media"'
  assert_contains "$instagram_output_dir/posts/instagram/index.html" 'CxOWiQNP2MO'
  exit 0
fi

assert_file "$output_dir/tags/index.html"
assert_file "$output_dir/tags/hugo/index.html"
assert_file "$output_dir/categories/engineering/index.html"
assert_contains "$output_dir/tags/hugo/index.html" 'https://outside.example/articles/hugo'
assert_contains "$output_dir/index.xml" '<link>https://outside.example/articles/hugo</link>'
assert_contains "$output_dir/index.xml" '<guid isPermaLink="true">https://outside.example/articles/hugo</guid>'
assert_contains "$output_dir/tags/hugo/index.xml" '<title>External article</title>'
assert_not_contains "$output_dir/tags/hugo/index.xml" '<title>Local fixture article</title>'
assert_contains "$output_dir/posts/local-article/index.html" '<link rel="canonical" href="https://example.test/posts/local-article/">'
assert_contains "$output_dir/posts/external-article/index.html" '<link rel="canonical" href="https://outside.example/articles/hugo">'
assert_contains "$output_dir/posts/local-article/index.html" 'property="og:image"'
assert_contains "$output_dir/404.html" 'Page not found'
assert_contains "$output_dir/404.html" 'href="/posts/"'
assert_contains "$output_dir/posts/local-article/index.html" 'class="goat-diagram"'
assert_contains "$output_dir/posts/local-article/index.html" 'class="fixture-goat"'
assert_contains "$output_dir/posts/local-article/index.html" 'Mermaid diagram source'
assert_contains "$output_dir/posts/local-article/index.html" 'A &lt; B'

build_metadata_fixture
assert_contains "$metadata_output_dir/posts/metadata-less/index.html" '<meta name="description" content="Notes on Apple platforms, macOS internals, smart homes, electronics, and engineering practice by Dmytro Hladkyi.">'
assert_not_contains "$metadata_output_dir/posts/metadata-less/index.html" '<meta name="description" content="BODY-CONTENT-MUST-NOT-BECOME-METADATA">'

build_instagram_fixture
assert_file "$instagram_output_dir/posts/instagram/index.html"
assert_contains "$instagram_output_dir/posts/instagram/index.html" 'class="instagram-media"'
assert_contains "$instagram_output_dir/posts/instagram/index.html" 'CxOWiQNP2MO'
