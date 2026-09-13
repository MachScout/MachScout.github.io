#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output_dir=$(mktemp -d)
trap 'rm -rf "$output_dir"' EXIT

test ! -f "$repo_dir/.gitmodules"
test ! -e "$repo_dir/themes/LoveIt"
test ! -e "$repo_dir/assets/css/_custom.scss"
if grep -F 'theme = "LoveIt"' "$repo_dir/hugo.toml" >/dev/null; then exit 1; fi
if grep -F 'submodules: recursive' "$repo_dir/.github/workflows/hugo.yml" >/dev/null; then exit 1; fi
hugo --source "$repo_dir" --destination "$output_dir" --gc --minify --baseURL "https://example.test/"
test -f "$output_dir/index.html"
test -f "$output_dir/posts/index.html"
test -f "$output_dir/about/index.html"
test -f "$output_dir/index.xml"

testing_article="$output_dir/posts/testing-low-level-macos-products/index.html"
ip_kvm_article="$output_dir/posts/using-ip-kvms-for-a-small-mac-cloud/index.html"
mac_cloud_article="$output_dir/posts/building-a-mac-cloud-with-ip-kvms/index.html"
unifi_article="$output_dir/posts/migrating-from-openwrt-to-unifi/index.html"
swift_concurrency_article="$output_dir/posts/swift-concurrency-vs-gcd-for-security-events/index.html"
about_page="$output_dir/about/index.html"
test -f "$testing_article"
test -f "$swift_concurrency_article"
test ! -e "$ip_kvm_article"
test ! -e "$mac_cloud_article"
if grep -F '/posts/using-ip-kvms-for-a-small-mac-cloud/' "$testing_article" >/dev/null; then
  printf 'published article links to draft IP KVM article\n' >&2
  exit 1
fi
grep -F 'id=table-of-contents-title>Contents' "$testing_article" >/dev/null
grep -F 'id=table-of-contents-title>Contents' "$unifi_article" >/dev/null
grep -F '<h4 id=host-and-guest-version-dependencies>' "$testing_article" >/dev/null
grep -F '<h4 id=provisioning-uuid>' "$testing_article" >/dev/null
grep -F '<h4 id=ssd-and-disk-behavior>' "$testing_article" >/dev/null
grep -F '<h4 id=the-two-vm-license-limit>' "$testing_article" >/dev/null
grep -F '<h4 id=cases-where-vms-are-better>' "$testing_article" >/dev/null
grep -F '<link rel=canonical href=https://www.apriorit.com/dev-blog/swift-concurrency-vs-gcd-for-security-events>' "$swift_concurrency_article" >/dev/null
grep -F '<meta name=robots content="noindex,follow">' "$swift_concurrency_article" >/dev/null
grep -F 'This article is published on www.apriorit.com.' "$swift_concurrency_article" >/dev/null
grep -F 'class="article-card article-card--external"' "$output_dir/index.html" >/dev/null
grep -F 'src=/posts/swift-concurrency-vs-gcd-for-security-events/featured-image.png' "$output_dir/index.html" >/dev/null
grep -F 'width=1774 height=887' "$output_dir/index.html" >/dev/null
if grep -F 'class="article-card article-card--external article-card--text-only"' "$output_dir/index.html" >/dev/null; then
  printf 'external Swift concurrency article unexpectedly rendered without a featured image\n' >&2
  exit 1
fi
grep -F 'href=https://www.apriorit.com/dev-blog/swift-concurrency-vs-gcd-for-security-events' "$output_dir/index.html" >/dev/null
grep -F 'href=/tags/swift/>Swift</a>' "$output_dir/index.html" >/dev/null
grep -F 'href=/tags/swiftconcurrency/>SwiftConcurrency</a>' "$output_dir/index.html" >/dev/null
grep -F 'href=/tags/gcd/>GCD</a>' "$output_dir/index.html" >/dev/null
grep -F 'href=/tags/endpointsecurity/>EndpointSecurity</a>' "$output_dir/index.html" >/dev/null
grep -F 'href=/tags/macos/>macOS</a>' "$output_dir/index.html" >/dev/null
if grep -F '>Macos</a>' "$output_dir/index.html" >/dev/null; then
  printf 'macOS taxonomy unexpectedly rendered as Macos\n' >&2
  exit 1
fi
if grep -F 'id=table-of-contents-title>Contents' "$about_page" >/dev/null; then
  printf 'unexpected table of contents in %s\n' "$about_page" >&2
  exit 1
fi
