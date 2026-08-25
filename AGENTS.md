## Overview

Hugo static site using the [LoveIt](https://github.com/dillonzq/LoveIt) theme (pinned as a git submodule at `themes/LoveIt`). Content is written in Markdown; the site deploys to GitHub Pages via a GitHub Actions workflow on push to `main`.

## Commands

```bash
# Start local dev server (includes drafts, full rebuild on change)
hugo server --buildDrafts --disableFastRender

# Production build (outputs to public/)
hugo --gc --minify

# Create a new post
hugo new posts/my-post-title.md
```

## Architecture

- **`hugo.toml`** — site config: base URL, title, locale, nav menu, and markup settings. `noClasses = false` is required for syntax highlighting with LoveIt.
- **`content/posts/`** — blog posts in Markdown with TOML front matter (`+++`). New posts default to `draft = true`.
- **`layouts/`** — theme overrides. Anything here shadows the equivalent file in `themes/LoveIt/layouts/`. Current overrides: custom shortcodes (`instagram`), diagram renderers (`goat`, `mermaid`), and X/Twitter embed partials.
- **`archetypes/default.md`** — template applied when `hugo new` creates a file.
- **`themes/LoveIt`** — git submodule; do not edit directly.

## Submodule setup

Clone with submodules or initialize after cloning:

```bash
git clone --recurse-submodules <repo-url>
# or after cloning:
git submodule update --init --recursive
```

To update the theme to a new release:

```bash
git -C themes/LoveIt fetch --tags origin
git -C themes/LoveIt checkout <latest-tag>
git add themes/LoveIt
```

## Deployment

Pushing to `main` triggers `.github/workflows/hugo.yml`, which builds with Hugo Extended `0.165.0` and deploys `public/` to GitHub Pages. To enable: in the GitHub repo go to **Settings → Pages → Build and deployment** and set Source to **GitHub Actions**.
