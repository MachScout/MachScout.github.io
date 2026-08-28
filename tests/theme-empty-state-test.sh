#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"

empty_output=$(build_fixture empty-states)
term_output=$(build_fixture empty-term)
trap 'rm -rf "$empty_output" "$term_output"' EXIT

assert_file "$empty_output/posts/index.html"
assert_file "$empty_output/tags/index.html"
assert_file "$term_output/tags/unused/index.html"

assert_contains "$empty_output/posts/index.html" 'There are no posts in this section yet.'
assert_contains "$empty_output/posts/index.html" 'href="/posts/"'
assert_contains "$empty_output/tags/index.html" 'There are no tags yet.'
assert_contains "$empty_output/tags/index.html" 'href="/posts/"'
assert_contains "$term_output/tags/unused/index.html" 'There are no posts in this tag yet.'
assert_contains "$term_output/tags/unused/index.html" 'href="/posts/"'
