## Overview

Self-contained Hugo static site with custom layouts, assets, and shortcodes. Content is Markdown, and GitHub Actions deploys it to GitHub Pages on pushes to `main` or `master`. There is no theme dependency or Git submodule.

## Commands

```bash
# Start local development with drafts and full rebuilds
hugo server --buildDrafts --disableFastRender

# Run the complete shell test suite
for test_file in tests/*-test.sh; do sh "$test_file"; done

# Production build (outputs to public/)
hugo --gc --minify

# Create a new post
hugo new posts/my-post-title/index.md
```

## Architecture

- **`hugo.toml`** — site configuration, including menus, font stacks in `params.fonts`, and markup settings.
- **`content/posts/`** — Markdown page bundles with TOML front matter. New posts are drafts; use `externalURL` only for absolute HTTP(S) source articles.
- **`layouts/`** — complete site templates, partials, heading/table render hooks, and `image`, `video`, and `youtube` shortcodes.
- **`assets/`** — custom CSS and JavaScript. `assets/css/tokens.css` defines the light/dark color tokens.
- **`archetypes/default.md`** — defaults for authoring a new post: description, tags, categories, and a table of contents.
- **`tests/`** — shell tests for rendering contracts and the standalone production build.

## Content conventions

Article-specific assets belong in the same page bundle as `index.md`. `featured-image.*` is automatically used in cards and as the hero; set `hideFeaturedImage = true` to omit only the hero. Shortcode image alt text is required unless the image is decorative, and YouTube embeds require a title.

## Deployment

`.github/workflows/hugo.yml` builds with Hugo Extended `0.165.0` and deploys `public/` to GitHub Pages. Keep the GitHub Pages actions and Hugo version intact; no submodule configuration belongs in this repository.
