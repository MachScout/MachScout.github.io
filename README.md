# Hugo blog

This is a self-contained Hugo site with custom layouts and assets. It has no theme submodule.

## Local development

Install Hugo Extended, then start a development server that includes drafts and performs full rebuilds:

```bash
brew install hugo
hugo server --buildDrafts --disableFastRender
```

Open the URL Hugo prints, normally `http://localhost:1313/`. Build the deployable site into `public/` with:

```bash
hugo --gc --minify
```

## Writing articles

Create a bundle for a local article:

```bash
hugo new posts/my-post-title/index.md
```

The generated front matter provides `description`, `tags`, `categories`, and `toc = true`. A local article can use the following shape:

```toml
+++
title = "My article"
date = 2026-08-26T12:00:00Z
description = "A concise summary for article lists and social previews."
tags = ["hugo"]
categories = ["Engineering"]
toc = true
+++
```

To link an article that is published elsewhere, add an absolute HTTP(S) `externalURL`. Its local page becomes an outbound notice and article cards link to the original:

```toml
+++
title = "An article published elsewhere"
date = 2026-08-26T12:00:00Z
description = "Why this external article is useful."
externalURL = "https://example.com/articles/original"
tags = ["reading"]
categories = ["Links"]
+++
```

Put article-specific images and videos alongside the bundle's `index.md`. A file named `featured-image` (for example, `featured-image.png`) is used on article cards and as the article hero. Cards intentionally use an empty image alt because the linked title names the article; add `featuredImageAlt = "Descriptive featured image"` when the hero image needs alternative text. Add `hideFeaturedImage = true` to front matter to keep it on cards but omit the hero.

Use the media shortcodes with page resources:

```md
{{< image src="diagram.png" alt="Architecture diagram" caption="The request path." class="theme-aware-diagram" >}}

{{< video src="demo.mp4" poster="poster.png" ratio="16/9" maxWidth="64rem" caption="A short demonstration." >}}

{{< youtube id="dQw4w9WgXcQ" title="Descriptive video title" >}}
```

`image` requires meaningful `alt` text unless `decorative="true"`; `video` accepts an optional local poster, `ratio`, and `maxWidth` up to the 64rem wide-media space; `youtube` requires both an ID and accessible title.

## Appearance

The font stacks live in `[params.fonts]` in `hugo.toml` (`body`, `heading`, and `mono`). Color tokens for the light and dark themes are in `assets/css/tokens.css`. The header control cycles through system, light, and dark settings; the system setting follows the visitor's operating-system preference.

## GitHub Pages

`.github/workflows/hugo.yml` deploys pushes to `main` (and `master`) with Hugo Extended `0.165.0`. To enable it, open **Settings → Pages** in the GitHub repository and select **GitHub Actions** as the build source. The workflow builds `public/` and deploys it with GitHub Pages; no submodule checkout is required.
