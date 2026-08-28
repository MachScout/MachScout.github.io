#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"

output_dir=$(build_fixture theme-site)
trap 'rm -rf "$output_dir"' EXIT

home="$output_dir/index.html"
about="$output_dir/about/index.html"
stylesheet=$(find "$output_dir/css" -name '*.css' -type f | head -n 1)
assert_file "$home"
assert_file "$about"
assert_contains "$home" '<header class="site-header">'
assert_contains "$home" 'Dmytro Hladkyi'
assert_contains "$home" 'href="/posts/"'
assert_contains "$home" 'href="/tags/"'
assert_contains "$home" 'href="/categories/"'
assert_contains "$home" 'href="/about/"'
assert_contains "$home" 'data-theme-toggle data-theme-mode="light" aria-label="Switch color theme to dark" aria-describedby="theme-status"'
assert_contains "$home" 'id="theme-status" role="status" aria-live="polite" aria-atomic="true"'
assert_contains "$home" 'data-nav-toggle'
assert_contains "$home" 'aria-expanded="false"'
assert_contains "$home" 'class="icon icon--menu"'
assert_not_contains "$home" 'class="theme-toggle__icon theme-toggle__icon--system"'
assert_contains "$home" 'class="theme-toggle__icon theme-toggle__icon--light"'
assert_contains "$home" 'class="theme-toggle__icon theme-toggle__icon--dark"'
assert_contains "$home" 'Powered by <a href="https://gohugo.io/">Hugo</a>'
assert_contains "$home" '<section class="home-intro">'
assert_contains "$home" 'class="home-intro__socials" aria-label="Social profiles"'
assert_contains "$home" 'href="https://github.com/MachScout" target="_blank" rel="noopener noreferrer"'
assert_contains "$home" 'href="https://www.linkedin.com/in/dmytro-hladkyi-a605791a4/" target="_blank" rel="noopener noreferrer"'
assert_contains "$home" 'href="https://x.com/MachScout" target="_blank" rel="noopener noreferrer"'
assert_contains "$home" '<p class="site-footer__copyright">© 2022–'
assert_not_contains "$home" 'Theme –'
assert_not_contains "$home" 'Theme -'
assert_contains "$home" 'css/site.min.'
assert_contains "$home" 'js/site.min.'
assert_contains "$home" 'localStorage.getItem'
assert_contains "$home" '<html lang="en" data-theme="light">'
assert_contains "$home" 'try {'
assert_contains "$stylesheet" 'html.js .site-nav{display:none'
assert_contains "$stylesheet" 'html.js .site-nav[data-open=true]{display:flex'
assert_contains "$stylesheet" 'html.js .site-nav-toggle{display:block'
assert_contains "$stylesheet" '.site-header{position:sticky;z-index:100;top:0'
assert_contains "$stylesheet" '.site-footer__inner{padding:2.5rem 0;text-align:center}'
assert_contains "$stylesheet" '#main-content.main-content--home{width:min(calc(100% - 2rem),var(--shell-width))}'
assert_contains "$stylesheet" '@media(prefers-reduced-motion:no-preference){html{scroll-behavior:smooth}'
assert_contains "$stylesheet" ':root{--color-canvas:#FAFBFC;--color-surface:#FFFFFF;--color-text:#1D232A;--color-muted:#5B6775;--color-border:#D9E0E8;--color-accent:#3273DC;--color-on-accent:#FFFFFF;--color-focus:#175FC9'
assert_contains "$stylesheet" ':root[data-theme=dark]{--color-canvas:#22262B;--color-surface:#1C2025;--color-text:#C5C9CE;--color-muted:#949BA4;--color-border:#3A424B;--color-accent:#68B4D4;--color-on-accent:#22262B'
assert_contains "$stylesheet" ':root[data-theme=dark] .article__content .chroma{color:#c5c9ce}'
assert_contains "$stylesheet" ':root[data-theme=dark] .article__content .chroma .err{color:#e28b8b}'
assert_contains "$stylesheet" 'background:var(--color-accent);color:var(--color-on-accent);transform:translateY(-150%)'
assert_contains "$home" '<meta name="theme-color" content="#22262B" media="(prefers-color-scheme: dark)">'
assert_contains "$about" '<main id="main-content"'
assert_not_contains "$about" '<time datetime="0001-01-01">'
assert_not_contains "$about" 'class="icon icon--calendar"'
assert_contains "$about" 'class="icon icon--clock"'
assert_contains "$about" 'Reading time: 1 min'
