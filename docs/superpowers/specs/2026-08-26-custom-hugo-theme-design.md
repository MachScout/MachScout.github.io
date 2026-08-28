# Custom Hugo Blog Theme Design

**Date:** 2026-08-26

## Objective

Replace the LoveIt git-submodule theme with a project-native Hugo presentation layer that has no package-manager or runtime framework dependency. The result must preserve the existing content, media workflow, header identity, and GitHub Pages deployment while establishing small, explicit components that can grow with the blog.

The site remains an English-language technical blog by Dmytro Hladkyi. Its primary job is to make long-form engineering articles comfortable to discover, scan, read, and cite.

## Constraints

- Use Hugo Extended 0.165.0 in CI and remain compatible with the locally installed Hugo 0.161.1.
- Keep all production templates and assets in the repository root under `layouts/` and `assets/`; do not create another theme package.
- Remove the LoveIt submodule and the `theme = "LoveIt"` configuration.
- Do not add npm, a JavaScript framework, a CSS framework, an icon package, or a third-party font CDN.
- Use vanilla JavaScript only for theme selection and the mobile navigation.
- Preserve current page bundles and shortcode calls without rewriting published article content.
- Treat accessibility, responsive behavior, and reduced-motion preferences as baseline requirements.
- Keep the production build deterministic. It must not fetch external Open Graph data.

## Architecture

The site will use Hugo's project-level template lookup rather than a formal theme directory:

- `layouts/_default/` owns the base template, single pages, section lists, taxonomy lists, taxonomy terms, RSS, and 404 output.
- `layouts/index.html` owns the home page.
- `layouts/partials/` contains focused components for document head, header, footer, article cards, article metadata, featured images, pagination, taxonomy links, and icons.
- `layouts/shortcodes/` contains the page-resource-aware image and video components and a privacy-enhanced YouTube embed.
- `layouts/_default/_markup/` contains heading and link render hooks plus any dependency-free diagram handling retained by the site.
- `assets/css/` contains ordered CSS modules for tokens, reset/base rules, layout, header/navigation, article lists, article content, media, code, and responsive behavior.
- `assets/js/` contains small independent modules for color-theme selection and mobile navigation.
- `tests/fixtures/` contains controlled Hugo content and resources used by shell integration tests.

Partials communicate through documented dictionaries when they need more than a page context. Shared decisions such as resolving an article destination or featured image live in one partial rather than being repeated in list, taxonomy, and RSS templates.

## Content Model

### Local articles

Existing branch bundles under `content/posts/<slug>/index.md` remain valid. The existing resource declaration is the preferred featured-image contract:

```toml
resources = [
  { name = "featured-image", src = "featured-image.jpg" }
]
```

If no resource is named `featured-image`, the templates may fall back to a page resource whose filename begins with `featured-image.`. Missing featured media is valid and produces a text-only card.

`hideFeaturedImage = true` suppresses the large featured image on the local article page without removing its thumbnail from lists.

### External articles

An article published elsewhere is represented by a normal entry in `content/posts/`, which lets it participate in chronological lists, tags, categories, and feeds:

```toml
+++
title = "Article title"
date = 2026-08-26
externalURL = "https://example.com/article"
description = "A short description of the article."
tags = ["macos"]
categories = ["engineering"]
resources = [
  { name = "featured-image", src = "featured-image.jpg" }
]
+++
```

`externalURL` must be an absolute `https://` or `http://` URL. A shared destination partial returns that URL for external entries and `.RelPermalink` for local entries.

For an external entry:

- the whole list card, title, and image use `externalURL`;
- links open in a new tab and include `rel="external noopener noreferrer"`;
- the card displays the destination hostname and a visible external-link indicator;
- tags and categories still point to this site's taxonomy pages;
- RSS item links and GUID-facing navigation use the original article URL;
- the local output is not presented as a readable article in site navigation;
- canonical metadata points to the external URL if the generated output is reached directly.

The repository stores title, description/summary, date, taxonomies, and image. Build-time metadata scraping is intentionally excluded because it would add network failures and nondeterministic content.

## Page Inventory and Navigation

The theme provides:

- a home page with the existing author introduction followed by recent articles;
- `/posts/` with all local and external entries in reverse chronological order and pagination;
- `/tags/` and `/categories/` overview pages;
- individual tag and category pages using the same article-card component;
- the existing `/about/` content page;
- a useful 404 page with a route back to recent posts;
- an RSS feed whose entry destinations match the visible cards.

The header keeps the current information architecture. The logo and `Dmytro Hladkyi` link to the home page on the left. Posts, Tags, Categories, About, and the color-theme control appear on the right. On narrow screens, the navigation becomes a keyboard-accessible disclosure controlled by a button with an accurate `aria-expanded` state. JavaScript is an enhancement: the navigation remains reachable when scripts fail.

## Visual System

The visual direction is a quiet technical notebook rather than a card dashboard. The home and archive pages use a single editorial stream. Each article row gives the title and metadata priority, with an image to the right on wide screens and above the text on small screens. External entries add a hostname and `↗` indicator without changing the overall rhythm.

The article body uses a readable column of approximately `48rem`. Featured images and intentionally wide media can expand to approximately `64rem`. The layout uses spacing and thin rules instead of ornamental containers.

The signature detail is a restrained heading anchor in the left margin. It appears on hover and keyboard focus, communicates deep-link behavior, and does not disturb reading.

### Palette

All colors are semantic CSS custom properties with light and dark values. The initial named values are:

- light canvas: `#FAFBFC`
- light surface: `#FFFFFF`
- dark canvas: `#111418`
- dark surface: `#181D23`
- primary light text: `#1D232A`
- primary dark text: `#E6EAF0`
- technical blue accent: `#3273DC`

Muted text, borders, focus rings, code surfaces, and media mattes derive from explicit companion variables rather than opacity layered unpredictably over the page.

### Typography

The default typography stays close to LoveIt's system rendering:

- body and headings: `-apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif`
- code: `"SFMono-Regular", Consolas, monospace`

`hugo.toml` exposes separate body, heading, and monospaced font stacks. The head partial maps them into `--font-body`, `--font-heading`, and `--font-mono`, allowing later changes without editing component styles.

### Color-theme behavior

With no saved choice, the site follows `prefers-color-scheme`. A visitor can select light, dark, or return to system behavior through an accessible control. The choice is saved in `localStorage`. A tiny early initialization script applies the resolved theme before the page paints to avoid a light-theme flash; the interactive behavior remains in the normal JavaScript asset. Controls expose an understandable label rather than relying on an unlabeled icon.

Motion is limited to short color and disclosure transitions and is disabled under `prefers-reduced-motion`.

## Article Layout and Rich Content

A local article is rendered in this order:

1. title;
2. description, publication date, reading time, tags, and categories;
3. featured image unless `hideFeaturedImage = true`;
4. table of contents when `toc = true`;
5. article body;
6. previous/next local article navigation when destinations exist.

Markdown headings from `#` through `#####` receive a complete type and spacing scale. The heading render hook preserves Hugo-generated IDs and adds a directly focusable anchor. The table of contents includes heading levels 1 through 5 and uses those same IDs. `toc = false` or an absent value omits it, so short articles remain uncluttered.

Article styles explicitly cover paragraphs, nested lists, task lists, blockquotes, horizontal rules, links, footnotes, inline code, fenced code, tables, and figures. Wide tables become horizontally scrollable on small screens. Syntax highlighting is generated by Hugo with classes and has matching light/dark styles; it requires no client-side highlighter.

## Featured Images and Image Shortcode

Featured images appear:

- as thumbnails on home, post, tag, and category lists;
- as a large image beneath metadata on local article pages;
- only in lists for external articles.

List thumbnails are lazy-loaded. The above-the-fold article featured image is loaded eagerly with high fetch priority. When Hugo can process the source format, templates generate intrinsic dimensions and responsive variants while preserving the original as a fallback. Alt text comes from a page parameter when supplied; decorative list thumbnails use an empty alt because the adjacent title describes their destination.

The existing image invocation remains supported:

```go-html-template
{{< image src="architecture.png" alt="Architecture diagram" caption="Lab architecture." class="theme-aware-diagram" >}}
```

The shortcode:

- resolves `src` from the current page bundle and fails the build with the page path when it is missing;
- requires meaningful `alt` text unless explicitly marked decorative;
- emits intrinsic width and height where available;
- supports an optional caption and class;
- adds an adaptive matte for PNG images;
- preserves `theme-aware-diagram` compatibility.

Transparent PNG diagrams use a soft light matte in light mode and a muted medium-gray matte in dark mode. This lowers perceived brightness while retaining contrast for black diagram lines. Photographic media receives only mild dark-mode dimming, which returns to full brightness on hover or keyboard focus.

## Video and YouTube

The existing local-video call remains valid:

```go-html-template
{{< video src="demo.mp4" caption="Demo." >}}
```

The expanded contract is:

```go-html-template
{{< video src="demo.mp4" poster="custom-poster.jpg" ratio="16/9" maxWidth="48rem" caption="Demo." >}}
```

The video shortcode resolves the video and optional poster from page resources. A missing resource fails the build with a precise error. Defaults are the existing static capybara poster, a `16/9` aspect ratio, and the current constrained presentation width. Output uses controls, `preload="metadata"`, `playsinline`, an MP4 source type, intrinsic aspect sizing, an adaptive background, and an optional figcaption.

YouTube uses a project-owned shortcode:

```go-html-template
{{< youtube id="VIDEO_ID" title="Video title" >}}
```

It requires both ID and accessible title, uses `https://www.youtube-nocookie.com/embed/`, lazy-loads the iframe, includes a restrictive `allow` list and fullscreen support, and shares the responsive video-frame styles. No YouTube script is loaded on pages without an embed.

## Other Existing Embeds and Diagrams

The Instagram wrapper and Hugo's internal X/Twitter partial compatibility remain available because they already exist in the project. They may load third-party resources only on pages where an author explicitly inserts them.

GOAT diagrams may be rendered through Hugo's dependency-free diagram API. The LoveIt-specific Mermaid renderer is not part of this initial replacement because the current published content does not use it and browser rendering would add a JavaScript dependency. A fenced Mermaid block must degrade to a readable code block rather than breaking the build; first-class Mermaid rendering can be added later as an isolated, optional feature.

## Metadata, Feeds, and Linking

The head partial generates:

- a title that combines page and site names without duplication;
- meta description from `description`, then `summary`, then site description;
- canonical URL using the external destination for external articles;
- Open Graph type, title, description, URL, and featured image;
- Twitter card metadata;
- color-scheme and theme-color metadata;
- RSS discovery and favicon/logo references where configured.

External links inside Markdown remain ordinary links. The heading/link rendering logic must not silently force every off-site link into a new tab. Only external-article cards use the deliberate new-tab behavior defined above.

## Error Handling and Empty States

Required shortcode parameters fail at build time with the shortcode name and source page. Missing optional media falls back cleanly: a card without an image becomes text-only, a local article without a featured image simply closes the gap, and a video without a custom poster uses the shared default.

Empty taxonomy and section pages show a short explanation and a route back to Posts rather than an empty shell. Pagination controls render only when another page exists. All user-visible labels are plain English and match the site's configured language.

## Testing Strategy

Implementation follows red-green-refactor cycles through shell integration tests that build controlled Hugo fixtures and assert generated behavior rather than template source text.

Tests cover:

- a local article card linking to its generated page;
- an external article card linking to `externalURL`, showing its hostname and safe link attributes;
- external entries appearing in taxonomy output and RSS with their original destinations;
- featured image output in lists and local articles, including `hideFeaturedImage`;
- headings H1 through H5, stable anchors, and a generated table of contents;
- compatible image and local-video shortcode output;
- custom video poster, aspect ratio, constrained width, and build failure for missing resources;
- privacy-enhanced YouTube output and build failure for missing required parameters;
- responsive navigation structure and accessible theme controls;
- home, posts, taxonomy, about, RSS, and 404 output;
- the complete existing content tree through `hugo --gc --minify`.

The final verification also includes rendered visual inspection at desktop and mobile widths in light and dark themes. It checks the home list, a long article, transparent PNG diagrams, local video, code blocks, tables, focus states, and reduced-motion behavior.

## Migration

The migration removes `theme = "LoveIt"`, `.gitmodules`, the LoveIt gitlink, and workflow submodule checkout. LoveIt-specific configuration is replaced with small site-owned parameters for navigation, home copy, font stacks, pagination, and social metadata. Existing URLs, page bundles, taxonomy names, header logo, author copy, and deployment base URL remain stable.

The LoveIt-dependent taxonomy and diagram overrides are either replaced by project-native equivalents or removed once their behavior is covered elsewhere. Published Markdown is not bulk-rewritten.

README and AGENTS documentation are updated to describe the custom architecture, media shortcodes, external-article front matter, local commands, and deployment without submodule setup.

## Acceptance Criteria

- The repository builds and deploys without the LoveIt submodule or any package-manager install step.
- The header contains the logo and site name on the left and Posts, Tags, Categories, About, and the theme control on the right.
- Light, dark, and system color modes work without an incorrect-theme flash and persist as designed.
- Home, post, taxonomy, About, RSS, and 404 pages are complete and responsive.
- Local and external articles share chronological lists; external cards visibly identify and open their original destination.
- Featured images appear in lists and at the top of local articles with the approved opt-out.
- Article content correctly renders and styles heading levels H1 through H5, anchors, and an optional beginning-of-article table of contents.
- Existing image and video calls continue to build, with adaptive media presentation in dark mode.
- Custom video posters and dimensions, YouTube embeds, and external article metadata work through documented interfaces.
- Automated fixture tests and the full minified production build pass.
- Desktop/mobile and light/dark visual inspection finds no overflow, unreadable contrast, inaccessible controls, or broken media.

## Out of Scope

- Full-text client-side search.
- Comments, reactions, analytics, or a newsletter integration.
- Automatic remote Open Graph scraping.
- A JavaScript-rendered Mermaid dependency.
- Turning the project-native layout into a reusable public Hugo theme package.
