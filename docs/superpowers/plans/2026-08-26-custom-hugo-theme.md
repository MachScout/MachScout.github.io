# Custom Hugo Blog Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace LoveIt with a dependency-light, project-native Hugo blog presentation layer that preserves current content and adds external articles, featured media, rich article navigation, and accessible light/dark themes.

**Architecture:** Hugo project-level layouts and focused partials own rendering; plain CSS is concatenated by Hugo Pipes, and two small vanilla JavaScript files provide theme selection and mobile navigation. Shell integration tests build controlled content fixtures and assert generated HTML, resources, feeds, and deliberate build failures.

**Tech Stack:** Hugo Extended 0.161.1 locally / 0.165.0 in CI, Go templates, HTML, plain CSS, vanilla JavaScript, POSIX shell tests.

**Spec:** `docs/superpowers/specs/2026-08-26-custom-hugo-theme-design.md`

## Global Constraints

- Keep production templates and assets in root-level `layouts/` and `assets/`; do not create a theme package.
- Remove LoveIt, its git submodule, and submodule checkout from deployment.
- Add no npm setup, client framework, CSS framework, icon dependency, syntax-highlighting script, or remote font.
- Preserve the existing page bundles and `image`/`video` shortcode calls.
- Use vanilla JavaScript only for theme selection and mobile navigation.
- Support Hugo Extended 0.161.1 and CI Hugo Extended 0.165.0.
- Store external article metadata locally; the build performs no remote metadata fetch.
- Use test-first red-green-refactor cycles and commit after every task.
- Do not edit published article Markdown in `content/posts/`.

## File Structure

- `layouts/_default/baseof.html`: shared document shell.
- `layouts/index.html`, `layouts/_default/list.html`, `layouts/_default/single.html`: home, collection, and content compositions.
- `layouts/_default/terms.html`, `layouts/_default/taxonomy.html`, `layouts/_default/term.html`, `layouts/_default/rss.xml`, `layouts/404.html`: taxonomy, feed, and error outputs across Hugo's current and fallback lookup paths.
- `layouts/partials/head.html`, `header.html`, `footer.html`: site chrome and asset pipeline.
- `layouts/partials/article/`: article destination, featured media, metadata, cards, TOC, and adjacent navigation.
- `layouts/partials/icons/`: small inline SVG symbols with no package dependency.
- `layouts/shortcodes/image.html`, `video.html`, `youtube.html`: validated responsive media.
- `layouts/_default/_markup/render-heading.html`, `render-codeblock-goat.html`, `render-codeblock-mermaid.html`: rich Markdown hooks and dependency-free fallbacks.
- `assets/css/*.css`: tokens, base, shell, lists, article, media, code, utilities.
- `assets/js/theme.js`, `navigation.js`: progressive client behavior.
- `tests/theme-*.sh`, `tests/lib/hugo-test.sh`, `tests/fixtures/theme-site/`: behavior tests and controlled content.

---

### Task 1: Site Shell, Config, Header, and Color Theme

**Files:**
- Create: `tests/lib/hugo-test.sh`
- Create: `tests/fixtures/theme-site/content/_index.md`
- Create: `tests/fixtures/theme-site/content/about/index.md`
- Create: `tests/theme-shell-test.sh`
- Modify: `hugo.toml`
- Create: `layouts/_default/baseof.html`
- Create: `layouts/partials/head.html`
- Create: `layouts/partials/header.html`
- Create: `layouts/partials/footer.html`
- Create: `layouts/index.html`
- Create: `layouts/_default/single.html`
- Create: `assets/css/tokens.css`
- Create: `assets/css/base.css`
- Create: `assets/css/shell.css`
- Create: `assets/css/utilities.css`
- Create: `assets/js/theme.js`
- Create: `assets/js/navigation.js`

**Interfaces:**
- Consumes: current menu entries, `[params.header.title]`, header logo, home profile title/subtitle, and author settings from `hugo.toml`.
- Produces: the `baseof.html` blocks `title`, `main`, and `scripts`; `data-theme="light|dark"` on `<html>`; `[data-theme-toggle]`; `[data-nav-toggle]`; compiled `css/site.css` and `js/site.js` resources used by every later page.

- [ ] **Step 1: Write the failing shell integration test**

Create a fixture home with ordinary Markdown and an About page, then create `tests/theme-shell-test.sh` using real Hugo output:

```sh
#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"

output_dir=$(build_fixture theme-site)
trap 'rm -rf "$output_dir"' EXIT

home="$output_dir/index.html"
about="$output_dir/about/index.html"
assert_file "$home"
assert_file "$about"
assert_contains "$home" '<header class="site-header">'
assert_contains "$home" 'Dmytro Hladkyi'
assert_contains "$home" 'href="/posts/"'
assert_contains "$home" 'href="/tags/"'
assert_contains "$home" 'href="/categories/"'
assert_contains "$home" 'href="/about/"'
assert_contains "$home" 'data-theme-toggle'
assert_contains "$home" 'data-nav-toggle'
assert_contains "$home" 'aria-expanded="false"'
assert_contains "$home" 'css/site.min.'
assert_contains "$home" 'js/site.min.'
assert_contains "$home" 'localStorage.getItem'
assert_contains "$about" '<main id="main-content"'
```

Implement `tests/lib/hugo-test.sh` with literal helpers:

```sh
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)

build_fixture() {
  fixture=$1
  destination=$(mktemp -d)
  hugo --source "$repo_dir" \
    --contentDir "$repo_dir/tests/fixtures/$fixture/content" \
    --destination "$destination" \
    --baseURL "https://example.test/" --quiet
  printf '%s\n' "$destination"
}

assert_file() { test -f "$1" || { printf 'missing file: %s\n' "$1" >&2; exit 1; }; }
assert_contains() { grep -F "$2" "$1" >/dev/null || { printf 'missing %s in %s\n' "$2" "$1" >&2; exit 1; }; }
assert_not_contains() { if grep -F "$2" "$1" >/dev/null; then printf 'unexpected %s in %s\n' "$2" "$1" >&2; exit 1; fi; }
```

- [ ] **Step 2: Run the test and verify RED**

Run: `sh tests/theme-shell-test.sh`

Expected: FAIL because `theme = "LoveIt"` cannot resolve the absent submodule layouts or because the generated page lacks `site-header` and theme controls.

- [ ] **Step 3: Implement the minimal project-native shell**

Remove `theme = "LoveIt"` from `hugo.toml`. Add font settings and TOC levels:

```toml
[params.fonts]
  body = '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif'
  heading = '-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif'
  mono = '"SFMono-Regular", Consolas, monospace'

[markup.tableOfContents]
  startLevel = 1
  endLevel = 5
  ordered = false
```

In `head.html`, concatenate the four CSS resources to a fingerprinted `css/site.min.css`, expose the three configurable font variables in an inline style, and include this early script before the stylesheet:

```html
<script>
  (function () {
    var saved = localStorage.getItem('color-theme');
    var dark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    document.documentElement.dataset.theme = saved === 'light' || saved === 'dark' ? saved : (dark ? 'dark' : 'light');
  }());
</script>
```

Build `header.html` from `.Site.Menus.main`. Use a logo `<img>` with intrinsic dimensions where Hugo exposes them, a text site name, a skip link, a real navigation landmark, a mobile disclosure button, and a three-state theme button whose accessible label describes the next state.

Concatenate `theme.js` and `navigation.js` into fingerprinted `js/site.min.js`. `theme.js` cycles `system → light → dark → system`, updates `data-theme`, listens for system changes while in system mode, and persists only explicit light/dark selections. `navigation.js` toggles `aria-expanded`, closes on Escape and after a mobile nav link activates, and does nothing when the required elements are absent.

Implement semantic light/dark variables and the approved responsive header in the four initial CSS files. Include visible `:focus-visible`, a visually hidden utility, reduced-motion handling, and a readable content fallback before later article-specific styles exist.

- [ ] **Step 4: Run the shell test and verify GREEN**

Run: `sh tests/theme-shell-test.sh`

Expected: PASS with no Hugo warning or missing-resource output.

- [ ] **Step 5: Commit**

```bash
git add hugo.toml layouts assets tests/lib tests/fixtures/theme-site tests/theme-shell-test.sh
git commit -m "feat: add custom Hugo site shell"
```

---

### Task 2: Article Lists, External Destinations, and Featured Thumbnails

**Files:**
- Create: `tests/fixtures/theme-site/content/posts/local-article/index.md`
- Create: `tests/fixtures/theme-site/content/posts/local-article/featured-image.svg`
- Create: `tests/fixtures/theme-site/content/posts/external-article/index.md`
- Create: `tests/fixtures/theme-site/content/posts/external-article/featured-image.svg`
- Create: `tests/theme-list-test.sh`
- Create: `layouts/partials/article/destination.html`
- Create: `layouts/partials/article/featured-resource.html`
- Create: `layouts/partials/article/featured.html`
- Create: `layouts/partials/article/card.html`
- Create: `layouts/partials/article/meta.html`
- Create: `layouts/partials/pagination.html`
- Modify: `layouts/index.html`
- Create: `layouts/_default/list.html`
- Create: `assets/css/list.css`
- Modify: `layouts/partials/head.html`

**Interfaces:**
- Consumes: shell blocks and compiled CSS list from Task 1; `.Params.externalURL`; named `featured-image` page resources.
- Produces: `article/destination.html` returning a validated dictionary with `url`, `isExternal`, `hostname`, `target`, and `rel`; `article/featured-resource.html` returning a page resource or empty value; `article/featured.html` accepting `page`, `variant`, and `eager`; shared `.article-card`; paginated home and section collections.

- [ ] **Step 1: Write failing list behavior tests**

The local fixture has title, date, description, tags, categories, `toc = true`, and a named SVG resource. The external fixture has a later date, `externalURL = "https://outside.example/articles/hugo"`, a summary, taxonomies, and a named SVG resource.

Create `tests/theme-list-test.sh`:

```sh
#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"
output_dir=$(build_fixture theme-site)
trap 'rm -rf "$output_dir"' EXIT

home="$output_dir/index.html"
posts="$output_dir/posts/index.html"
assert_file "$posts"
assert_contains "$home" 'class="article-card article-card--external"'
assert_contains "$home" 'href="https://outside.example/articles/hugo"'
assert_contains "$home" 'target="_blank"'
assert_contains "$home" 'rel="external noopener noreferrer"'
assert_contains "$home" 'outside.example'
assert_contains "$home" 'External article'
assert_contains "$home" 'href="/posts/local-article/"'
assert_contains "$home" 'loading="lazy"'
assert_contains "$home" 'featured-image.svg'
assert_not_contains "$home" 'article-card__placeholder'
assert_contains "$posts" 'Local fixture article'
```

Add a dedicated invalid fixture under `tests/fixtures/invalid-external/content/posts/bad/index.md` and assert that Hugo exits nonzero with `externalURL must be an absolute http(s) URL` when given `externalURL = "/relative"`.

- [ ] **Step 2: Run the list tests and verify RED**

Run: `sh tests/theme-list-test.sh`

Expected: FAIL because no shared cards or external destination validation exist.

- [ ] **Step 3: Implement destination and featured-resource partials**

`destination.html` validates and returns a stable dictionary so cards, metadata, and RSS do not repeat URL classification:

```go-html-template
{{- $external := .Params.externalURL | default "" -}}
{{- if $external -}}
{{- if not (findRE `^https?://` $external) -}}
    {{- errorf "externalURL must be an absolute http(s) URL: %q in %s" $external .Path -}}
{{- end -}}
  {{- $parsed := urls.Parse $external -}}
  {{- return (dict "url" $external "isExternal" true "hostname" $parsed.Hostname "target" "_blank" "rel" "external noopener noreferrer") -}}
{{- end -}}
{{- return (dict "url" .RelPermalink "isExternal" false "hostname" "" "target" "" "rel" "") -}}
```

`featured-resource.html` first tries `.Resources.GetMatch "featured-image"`, then `featured-image.*`, and returns no value when neither exists. `featured.html` accepts a dictionary with `page`, `variant` (`card` or `hero`), and `eager`. For raster images it generates same-format 480px and 960px candidates only when the original is wider, retains the original URL as the `src` fallback, and emits intrinsic dimensions. Unsupported resources such as SVG use their original URL and omit unavailable dimensions.

- [ ] **Step 4: Implement the shared article card and list pages**

The card receives a page. It resolves destination and image once, decorates external entries with hostname plus visible `↗` and screen-reader text, keeps taxonomy links separately focusable, and uses text-only layout when the image is absent. The image link is decorative (`alt=""`) because the adjacent linked title names the same destination.

Home selects regular pages from `posts`, applies the configured home pagination size, and renders the existing profile title/subtitle before the card stream. `_default/list.html` renders section pages through `.Paginate`. Add only existing previous/next pagination controls.

Create `list.css` for the wide text/image row, external indicator, taxonomy chips, text-only variant, and mobile image-first stack. Add it to the CSS concatenation in `head.html`.

- [ ] **Step 5: Run list and shell tests and verify GREEN**

Run: `sh tests/theme-shell-test.sh && sh tests/theme-list-test.sh`

Expected: both PASS.

- [ ] **Step 6: Commit**

```bash
git add layouts assets/css tests
git commit -m "feat: add local and external article lists"
```

---

### Task 3: Local Article, Featured Hero, Headings, and TOC

**Files:**
- Modify: `tests/fixtures/theme-site/content/posts/local-article/index.md`
- Create: `tests/theme-article-test.sh`
- Modify: `layouts/_default/single.html`
- Create: `layouts/partials/article/toc.html`
- Create: `layouts/partials/article/adjacent.html`
- Create: `layouts/_default/_markup/render-heading.html`
- Create: `layouts/_default/_markup/render-table.html`
- Create: `assets/css/article.css`
- Create: `assets/css/code.css`
- Modify: `layouts/partials/head.html`
- Modify: `layouts/partials/head.html`

**Interfaces:**
- Consumes: destination, featured-resource, and metadata partials from Task 2.
- Produces: stable heading anchors `.heading-anchor`; optional `.table-of-contents`; eager `.article-hero`; readable H1-H5 and rich Markdown styles.

- [ ] **Step 1: Write a failing generated-article test**

Put literal `# Level one` through `##### Level five`, a table, blockquote, fenced code, and `toc = true` in the local fixture. Create `tests/theme-article-test.sh`:

```sh
#!/bin/sh
set -eu
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib/hugo-test.sh"
output_dir=$(build_fixture theme-site)
trap 'rm -rf "$output_dir"' EXIT
page="$output_dir/posts/local-article/index.html"

assert_contains "$page" '<article class="article">'
assert_contains "$page" 'class="article-hero"'
assert_contains "$page" 'fetchpriority="high"'
assert_contains "$page" 'class="table-of-contents"'
assert_contains "$page" 'href="#level-one"'
assert_contains "$page" '<h1 id="level-one"'
assert_contains "$page" '<h5 id="level-five"'
assert_contains "$page" 'class="heading-anchor"'
assert_contains "$page" 'aria-label="Link to Level five"'
assert_contains "$page" '<div class="table-scroll">'
assert_contains "$page" 'Reading time'
```

Add another local fixture with `hideFeaturedImage = true` and assert its single page omits `article-hero` while its list card still contains the resource.

- [ ] **Step 2: Run the article test and verify RED**

Run: `sh tests/theme-article-test.sh`

Expected: FAIL because the single composition, heading hook, and TOC wrapper are absent.

- [ ] **Step 3: Implement the article composition and heading hook**

For external entries, `single.html` renders a short outbound notice and canonical destination rather than pretending to contain the article; `head.html` also emits `robots=noindex,follow` for this generated local notice. For local entries, render title, metadata, eager featured image, optional TOC, `.Content`, and adjacent local entries.

The heading hook uses `.Anchor`, `.Level`, and `.PlainText`:

```go-html-template
<h{{ .Level }} id="{{ .Anchor }}">
  {{- .Text | safeHTML -}}
  <a class="heading-anchor" href="#{{ .Anchor }}" aria-label="Link to {{ .PlainText }}">#</a>
</h{{ .Level }}>
```

Use `.TableOfContents` only when `.Params.toc` is true and the generated TOC is nonempty. Implement `render-table.html` with Hugo's table render-hook context and wrap `.THead`/`.TBody` in `<div class="table-scroll"><table>…</table></div>`; Hugo 0.161.1 is the tested minimum. The output must require no client JavaScript.

- [ ] **Step 4: Add article and code CSS**

Implement the approved `48rem` reading column and `64rem` media width, H1-H5 scale, left-gutter anchor, accessible TOC, responsive tables, lists, footnotes, blockquotes, inline/fenced code, and Hugo class-based Chroma colors for both themes. Add both files to the CSS concatenation.

- [ ] **Step 5: Run all current tests and verify GREEN**

Run: `sh tests/theme-shell-test.sh && sh tests/theme-list-test.sh && sh tests/theme-article-test.sh`

Expected: all PASS.

- [ ] **Step 6: Commit**

```bash
git add layouts assets/css tests
git commit -m "feat: add rich local article layout"
```

---

### Task 4: Image, Local Video, and YouTube Shortcodes

**Files:**
- Modify: `tests/fixtures/video-shortcode/content/posts/video/index.md`
- Create: `tests/fixtures/theme-site/content/posts/local-article/media.svg`
- Create: `tests/fixtures/theme-site/content/posts/local-article/poster.svg`
- Create: `tests/fixtures/theme-site/content/posts/local-article/test-video.mp4` by copying the existing tiny committed fixture media
- Create: `tests/theme-media-test.sh`
- Modify: `tests/video-shortcode-test.sh`
- Create: `layouts/shortcodes/image.html`
- Modify: `layouts/shortcodes/video.html`
- Create: `layouts/shortcodes/youtube.html`
- Create: `assets/css/media.css`
- Modify: `layouts/partials/head.html`

**Interfaces:**
- Consumes: page bundles, shared static capybara poster, article/media width tokens.
- Produces: `.media-figure`, `.media-frame`, `.media-frame--png`, `.video-card`, and privacy-enhanced YouTube markup; build-time errors for missing required parameters/resources.

- [ ] **Step 1: Write failing media behavior tests**

Add these calls to controlled fixture content:

```go-html-template
{{< image src="media.svg" alt="Fixture diagram" caption="Diagram caption." class="theme-aware-diagram" >}}
{{< video src="test-video.mp4" poster="poster.svg" ratio="4/3" maxWidth="36rem" caption="Custom clip." >}}
{{< youtube id="dQw4w9WgXcQ" title="Fixture YouTube video" >}}
```

The test asserts real output:

```sh
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
```

Create invalid fixtures for missing image, missing video, missing YouTube ID, and missing YouTube title. Each build must exit nonzero and contain the shortcode name plus source page.

- [ ] **Step 2: Run the media tests and verify RED**

Run: `sh tests/video-shortcode-test.sh && sh tests/theme-media-test.sh`

Expected: the old video test may pass, while the expanded media test fails on the absent image/YouTube contracts and custom parameters.

- [ ] **Step 3: Implement validated media shortcodes**

The image shortcode resolves `.Page.Resources.GetMatch`, validates nonempty `src` and `alt` unless `decorative=true`, emits intrinsic dimensions for processable resources, preserves the custom class, and adds `media-frame--png` based on media type/subtype or extension.

The video shortcode keeps current default output behavior but resolves an optional page-resource poster, validates ratios against `^[0-9]+([.][0-9]+)?/[0-9]+([.][0-9]+)?$`, constrains `maxWidth` with `^[0-9]+([.][0-9]+)?(px|rem|em|vw|%)$`, and uses escaped CSS custom properties. Use the custom page resource when supplied and the static capybara poster otherwise; a `poster` value never resolves from `static/` implicitly.

The YouTube shortcode requires ID and title and emits only the iframe needed on that page:

```html
<iframe src="https://www.youtube-nocookie.com/embed/ID" title="TITLE" loading="lazy"
  referrerpolicy="strict-origin-when-cross-origin"
  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
  allowfullscreen></iframe>
```

- [ ] **Step 4: Add adaptive media CSS**

Use separate light/dark media matte variables. PNG frames get the adaptive matte; photos get mild dark-mode brightness reduction restored on hover/focus. Local video and YouTube share responsive ratio/max-width primitives. Captions remain readable and do not exceed the media width.

- [ ] **Step 5: Run all tests and verify GREEN**

Run: `for test_file in tests/*-test.sh; do sh "$test_file"; done`

Expected: every test exits 0.

- [ ] **Step 6: Commit**

```bash
git add layouts/shortcodes layouts/partials/head.html assets/css tests
git commit -m "feat: add responsive image and video embeds"
```

---

### Task 5: Taxonomies, RSS, SEO Metadata, Diagrams, and 404

**Files:**
- Create: `tests/theme-discovery-test.sh`
- Create: `layouts/_default/terms.html`
- Create: `layouts/_default/taxonomy.html`
- Create: `layouts/_default/term.html`
- Delete: `layouts/term/list.html`
- Create: `layouts/_default/rss.xml`
- Create: `layouts/404.html`
- Modify: `layouts/partials/head.html`
- Create: `layouts/partials/icons/external.html`
- Replace: `layouts/_default/_markup/render-codeblock-goat.html`
- Replace: `layouts/_default/_markup/render-codeblock-mermaid.html`
- Modify: `layouts/shortcodes/instagram.html`
- Create: `assets/css/taxonomy.css`

**Interfaces:**
- Consumes: shared card, destination, featured-resource, shell, and metadata contracts.
- Produces: complete term lists, external-aware RSS item URLs, canonical/Open Graph/Twitter metadata, dependency-free GOAT rendering, readable Mermaid fallback, and 404 output.

- [ ] **Step 1: Write failing discovery tests**

Create `tests/theme-discovery-test.sh` that builds the main fixture and asserts:

```sh
assert_file "$output_dir/tags/index.html"
assert_file "$output_dir/tags/hugo/index.html"
assert_file "$output_dir/categories/engineering/index.html"
assert_contains "$output_dir/tags/hugo/index.html" 'https://outside.example/articles/hugo'
assert_contains "$output_dir/index.xml" '<link>https://outside.example/articles/hugo</link>'
assert_contains "$output_dir/index.xml" '<guid>https://outside.example/articles/hugo</guid>'
assert_contains "$output_dir/posts/local-article/index.html" '<link rel="canonical" href="https://example.test/posts/local-article/">'
assert_contains "$output_dir/posts/external-article/index.html" '<link rel="canonical" href="https://outside.example/articles/hugo">'
assert_contains "$output_dir/posts/local-article/index.html" 'property="og:image"'
```

Run `hugo --source "$repo_dir" --contentDir ... --destination ... --renderToMemory` with the 404 kind or use the full site output to assert `404.html` includes `Page not found` and `/posts/`.

- [ ] **Step 2: Run discovery tests and verify RED**

Run: `sh tests/theme-discovery-test.sh`

Expected: FAIL because terms, external-aware RSS, complete metadata, and 404 output do not yet exist.

- [ ] **Step 3: Implement taxonomy, feed, SEO, and error outputs**

Terms pages list each term with its post count. Individual taxonomy pages use the shared cards and pagination. Provide `terms.html`, `taxonomy.html`, and `term.html` fallbacks for the supported Hugo lookup paths and delete the LoveIt-specific `layouts/term/list.html` contract. RSS selects regular pages from `posts`, resolves every item through `article/destination.html`, and XML-escapes title, permalink, description, and dates. Local GUIDs use permalink with `isPermaLink="true"`; external GUIDs use `externalURL` with `isPermaLink="true"`. Feed descriptions use the locally stored description or summary, never scraped remote body content.

Enhance `head.html` with description fallback (`description → summary → site description`), canonical destination, Open Graph type/title/description/url/image, Twitter summary card, RSS discovery, `color-scheme`, and light/dark theme colors. Do not duplicate a site title already present in `.Title`.

Implement 404 with plain English guidance and a Posts action. Replace the LoveIt-dependent GOAT hook with Hugo's native diagram rendering supported by the version floor. Replace Mermaid rendering with an escaped, labeled code block fallback and no client dependency. Replace the LoveIt-dependent Instagram partial call with Hugo's internal Instagram shortcode template; retain the existing X/Twitter internal-template wrappers.

- [ ] **Step 4: Add taxonomy styles and run all tests**

Add taxonomy overview and empty-state styles to the CSS pipeline.

Run: `for test_file in tests/*-test.sh; do sh "$test_file"; done`

Expected: every test exits 0.

- [ ] **Step 5: Commit**

```bash
git add layouts assets/css tests
git commit -m "feat: add discovery pages and metadata"
```

---

### Task 6: Remove LoveIt, Update Deployment and Documentation, Verify Production

**Files:**
- Delete: `.gitmodules`
- Delete: gitlink `themes/LoveIt`
- Delete: `assets/css/_custom.scss`
- Modify: `.github/workflows/hugo.yml`
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`
- Modify: `archetypes/default.md`
- Create: `tests/production-build-test.sh`

**Interfaces:**
- Consumes: all completed template, asset, content, and test contracts.
- Produces: a self-contained repository, accurate contributor documentation, and the final production verification entry point.

- [ ] **Step 1: Write the failing production/migration test**

Create `tests/production-build-test.sh`:

```sh
#!/bin/sh
set -eu
repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
output_dir=$(mktemp -d)
trap 'rm -rf "$output_dir"' EXIT

test ! -f "$repo_dir/.gitmodules"
test ! -e "$repo_dir/themes/LoveIt"
if grep -F 'theme = "LoveIt"' "$repo_dir/hugo.toml" >/dev/null; then exit 1; fi
if grep -F 'submodules: recursive' "$repo_dir/.github/workflows/hugo.yml" >/dev/null; then exit 1; fi
hugo --source "$repo_dir" --destination "$output_dir" --gc --minify --baseURL "https://example.test/"
test -f "$output_dir/index.html"
test -f "$output_dir/posts/index.html"
test -f "$output_dir/about/index.html"
test -f "$output_dir/index.xml"
```

- [ ] **Step 2: Run the production test and verify RED**

Run: `sh tests/production-build-test.sh`

Expected: FAIL because `.gitmodules`, the LoveIt gitlink, and workflow submodule checkout still exist.

- [ ] **Step 3: Complete migration cleanup**

Remove `.gitmodules`, remove the `themes/LoveIt` gitlink, remove superseded `_custom.scss`, and delete `submodules: recursive` from checkout. Keep Hugo 0.165.0 and all GitHub Pages steps unchanged.

Update the archetype to include explicit `description`, `tags`, `categories`, and `toc = true` defaults without adding an external URL to normal posts.

Rewrite README setup and authoring documentation to cover:

- local development and production commands;
- no submodule setup;
- local and external article front matter;
- featured images and `hideFeaturedImage`;
- image, video, and YouTube shortcode examples;
- font-stack settings and color themes;
- GitHub Pages deployment.

Update AGENTS.md and CLAUDE.md so future agents do not reintroduce LoveIt assumptions.

- [ ] **Step 4: Run complete automated verification**

Run:

```bash
for test_file in tests/*-test.sh; do
  sh "$test_file"
done
hugo --gc --minify
git diff --check
```

Expected: every test exits 0, both Hugo builds complete without errors, and `git diff --check` prints nothing.

- [ ] **Step 5: Inspect rendered pages**

Start `hugo server --buildDrafts --disableFastRender` and inspect the generated site at desktop and mobile widths. Check home, Posts, Tags, Categories, About, one long article, its TOC, H1-H5 anchors, featured image, transparent PNG diagrams, local video, light/dark/system controls, mobile menu, keyboard focus, code, tables, and reduced motion. Capture screenshots for light/dark desktop and mobile evidence.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "chore: complete migration from LoveIt"
```

---

## Final Review

After all six tasks pass their task-scoped reviews, generate a whole-branch review package from the pre-implementation base to `HEAD`. A fresh reviewer must compare the result against the full design spec, inspect all deferred findings from the SDD ledger, and report spec compliance and code quality separately. Any Critical or Important findings receive one consolidated fix wave and one scoped re-review before final verification.
