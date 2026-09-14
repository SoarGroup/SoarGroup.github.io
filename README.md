# Soar Website

## ⚠️⚠️⚠️ WORK IN PROGRESS ⚠️⚠️⚠️

This repository contains the source for the (new as of 2024) homepage for the
Soar cognitive architecture, including source for the PDF's distributed with Soar.

The website is not yet fully migrated from the old site, and is still under construction.

The site is built with [Zensical](https://zensical.org/), a static site
generator from the Material for MkDocs team that uses Markdown files to
generate a website. It reads the existing `mkdocs.yml` config and renders
with the Material "classic" theme variant.

Large files that are not displayed but rather downloaded should not be stored here;
instead, put them in the [website downloads repository](https://github.com/SoarGroup/website-downloads)
and link to them here.

## Setup/Running

```shell
python -m venv venv
source venv/bin/activate # (or venv\Scripts\activate on Windows)
pip install -r requirements.txt
zensical serve # add -s to abort on any warnings; zensical build for a one-off build
```

## Deployment

The site is deployed to GitHub Pages automatically as long as the build workflows
don't fail. Run it locally to ensure you haven't introduced an error, and then
just push your commit to the `main` branch and the site will be updated automatically.

Deployment uses the GitHub Actions Pages pipeline (`.github/workflows/publish.yml`,
`zensical build` + `actions/deploy-pages`). The repository's *Settings → Pages →
Build and deployment → Source* must be set to **GitHub Actions**.

## Updates for New Soar Versions

*   Update the `soar_version` variable in `mkdocs.yml`.
*   Add announcement with link to `docs/index.md`.
*   Run the link-checker (manually triggered GH action workflow) to ensure all
    new release artifact links are valid.
