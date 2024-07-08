# https://www.mkdocs.org/user-guide/configuration/#hooks

import re

from pathlib import Path
from mkdocs.plugins import BasePlugin

# Convert image links to figures: modified from https://github.com/Jackiexiao/mkdocs-img2figv2-plugin
# to support absolute URLs

IMAGE_REGEX = re.compile(r'!\[(.*?)\]\((.*?)\)(\{[^\}]*\})?', flags=re.IGNORECASE)

def on_page_markdown(markdown, **kwargs):
    markdown = re.sub(IMAGE_REGEX, modify_match, markdown)
    return markdown

def modify_match(match):
    caption, image_link, attr_list = match.groups()

    # If the image link is not an absolute URL, make it relative to the containing folder
    if not (image_link.startswith('http://') or image_link.startswith('https://')):
        image_link = ('..' / Path(image_link)).as_posix()
    if attr_list:
        attr_list = attr_list.replace('{', '').replace('}', '')
    else:
        attr_list = ''

    return (
        r'<figure class="figure-image">'
        rf'  <img src="{image_link}" alt="{caption}" {attr_list}>'
        rf'  <figcaption>{caption}</figcaption>'
        r'</figure>'
    )

