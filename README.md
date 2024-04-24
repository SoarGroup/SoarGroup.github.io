# Soar Website

## ⚠️⚠️⚠️ WORK IN PROGRESS ⚠️⚠️⚠️

This repository contains the source for the (new as of 2024) homepage for the Soar cognitive architecture, including source for the PDF's distributed with Soar.

The website is not yet fully migrated from the old site, and is still under construction.

The site is built using the [MkDocs](https://www.mkdocs.org/), a static site generator that uses Markdown files to generate a website. The theme is [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/).

## Setup/Running

    python -m venv
    source venv/bin/activate (or venv\Scripts\Activate on Windows)
    pip install -r requirements.txt
    mkdocs serve

## Deployment

The site is deployed to GitHub Pages automatically as long as the build workflows don't fail.
