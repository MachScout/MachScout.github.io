# Hugo blog

Minimal Hugo blog using the `LoveIt` theme as a git submodule.

## Local development

Install Hugo Extended:

```bash
brew install hugo
```

Update Hugo later:

```bash
brew upgrade hugo
```

Start the local server:

```bash
hugo server --buildDrafts --disableFastRender
```

Open the URL printed by Hugo, usually `http://localhost:1313/`.

## GitHub Pages

This repository includes `.github/workflows/hugo.yml`.

1. Push the repository to GitHub.
2. In the GitHub repository, open `Settings` -> `Pages`.
3. Under `Build and deployment`, set `Source` to `GitHub Actions`.
4. Push to `main`, or run the workflow manually from the `Actions` tab.

The workflow checks out the `LoveIt` submodule, installs Hugo Extended `0.161.1`, builds the site into `public/`, and deploys it to GitHub Pages.

## Submodules

Clone this repository with submodules:

```bash
git clone --recurse-submodules <repo-url>
```

If you already cloned it:

```bash
git submodule update --init --recursive
```

Update the theme later:

```bash
git -C themes/LoveIt fetch --tags origin
git -C themes/LoveIt checkout <latest-tag>
git add themes/LoveIt
```
