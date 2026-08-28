# Final custom Hugo theme review fix wave

**Implementation base:** `487b3cb55026311daa560c8c6a904606bb14f40a`
**Commit:** `fix: resolve final Hugo theme review findings` (this report is included in that single coherent commit)

## TDD evidence

The baseline suite passed before the review tests were added. The following fixture-backed assertions were then added before their implementation changes. The first RED run produced the expected failures:

| Contract | RED command and observed failure | GREEN command |
| --- | --- | --- |
| Progressive mobile navigation and guarded early storage | `sh tests/theme-shell-test.sh` exited 1: missing `try {` in rendered home HTML; the new no-JS CSS-marker assertions were also absent before the change. | `sh tests/theme-shell-test.sh` exited 0. |
| Context-scoped taxonomy feeds | `sh tests/theme-discovery-test.sh` exited 1 because the Hugo term feed contained `Local fixture article`, unrelated to the `hugo` term. | `sh tests/theme-discovery-test.sh` exited 0. |
| Hero alt text | `sh tests/theme-article-test.sh` exited 1: missing `alt="Local fixture featured image"`. | `sh tests/theme-article-test.sh` exited 0. |
| Explicit empty states | `sh tests/theme-empty-state-test.sh` exited 1: missing `There are no posts in this section yet.` | `sh tests/theme-empty-state-test.sh` exited 0. |
| Card overlay and motion | `sh tests/theme-list-test.sh` exited 1: missing the external card primary link. | `sh tests/theme-list-test.sh` exited 0. |
| Wide media | `sh tests/theme-media-test.sh` exited 1 because the generated stylesheet still capped media at `48rem`. | `sh tests/theme-media-test.sh` exited 0. |

The complete suite and production build were run after the fixes; both exited 0.

## Finding-to-change map

| Finding | Implementation | Regression coverage |
| --- | --- | --- |
| Mobile navigation remains reachable without JavaScript; Escape restores the toggle when menu focus is active. | `layouts/partials/head.html` adds the early `js` class only after JavaScript starts and catches storage errors. `assets/css/shell.css` keeps the mobile nav visible and toggle hidden by default, applying disclosure rules only under `html.js`. `assets/js/navigation.js` closes an open menu on Escape and restores focus when appropriate. | `tests/theme-shell-test.sh` checks rendered no-JS HTML, guarded storage access, and compiled `html.js` disclosure rules. |
| Taxonomy RSS includes only pages in the current term. | `layouts/_default/rss.xml` starts with filtered context `.RegularPages`, retaining site-wide post selection only for home and `/posts/`. | `tests/theme-discovery-test.sh` verifies `/tags/hugo/index.xml` includes the external Hugo article and excludes the unrelated local article. |
| Cards remain decorative; hero uses documented alt text. | `layouts/partials/article/featured.html` consumes `featuredImageAlt` for the `hero` variant only. `README.md` documents the front-matter field and intentional empty card alt. | The local fixture supplies `featuredImageAlt`; `tests/theme-article-test.sh` checks hero output and `tests/theme-list-test.sh` checks card `alt=""`. |
| Empty section, taxonomy, term, and terms views explain the absence and link to Posts. | `layouts/_default/list.html`, `taxonomy.html`, `term.html`, and `terms.html` render explicit empty-state copy plus `/posts/`. | New `empty-states` and `empty-term` fixtures are asserted by `tests/theme-empty-state-test.sh`. |
| List thumbnails respect reduced motion. | `assets/css/list.css` limits thumbnail transition and hover scale to `prefers-reduced-motion: no-preference`. | `tests/theme-list-test.sh` checks the compiled motion media query. |
| Media can use the approved 64rem wide-media space. | `assets/css/media.css` has a 64rem default and expands article media at the existing 66rem wide-layout breakpoint while bounding any value to 64rem. `README.md` documents this. | `tests/theme-media-test.sh` checks both default and wide-media generated CSS. |
| TOC does not render an empty wrapper. | `layouts/partials/article/toc.html` requires a generated TOC list entry. | New `toc-without-headings` fixture is asserted by `tests/theme-article-test.sh`. |
| Early theme selection tolerates blocked local storage. | `layouts/partials/head.html` wraps the early `localStorage.getItem` and falls back to the system media query. | `tests/theme-shell-test.sh` checks the rendered guarded path; `assets/js/theme.js` already guards persistence. |
| External cards have a full-card primary destination without blocking taxonomy links. | `layouts/partials/article/card.html` adds an accessible external primary overlay. `assets/css/list.css` layers image/title/taxonomy controls above it and gives the overlay visible keyboard focus. | `tests/theme-list-test.sh` checks overlay markup, taxonomy link behavior, and compiled layering rules. |

## Files changed

- Rendering and behavior: `layouts/partials/head.html`, `layouts/_default/rss.xml`, list/taxonomy templates, article card/featured/TOC partials, `assets/js/navigation.js`, and `assets/css/{shell,list,media}.css`.
- Tests and fixtures: focused theme test scripts, empty-state fixtures, the empty-TOC fixture, and hero-alt fixture front matter.
- Documentation: `README.md`.

## Final verification

- `for test_file in tests/*-test.sh; do sh "$test_file"; done`
- `hugo --gc --minify`
- `git diff --check`

All commands exited 0. The production build used Hugo Extended 0.161.1 and completed with 31 pages and no warnings.

## Concerns

No known functional concerns. The no-JavaScript behavior is covered as a generated HTML/CSS contract because this dependency-free site has no browser test runner; a manual keyboard check remains useful when changing the header interaction in the future.
