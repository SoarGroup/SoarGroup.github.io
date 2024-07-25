# https://www.mkdocs.org/user-guide/configuration/#hooks

import re

from pathlib import Path
from mkdocs.plugins import BasePlugin

# Convert image links to figures: modified from https://github.com/Jackiexiao/mkdocs-img2figv2-plugin
# to support absolute URLs

IMAGE_REGEX = re.compile(r'!\[(.*?)\]\((.*?)\)(\{[^\}]*\})?', flags=re.IGNORECASE)

def on_page_markdown(markdown, page, **kwargs):
    modifier = get_image_link_modifier(page.file.abs_src_path)
    markdown = re.sub(IMAGE_REGEX, modifier, markdown)
    return markdown

def get_image_link_modifier(file_path):
    def modify_match(match):
        caption, image_link, attr_list = match.groups()

        is_absolute = image_link.startswith('http://') or image_link.startswith('https://')
        is_explicit_relative = image_link.startswith('./') or image_link.startswith('../')

        # If the image link is underspecified, make it relative to the containing folder
        # TODO: this is really confusing because an index.md in a folder will require
        # different paths; re-do links and get rid of this.
        if not (is_absolute or is_explicit_relative):
            image_link = ('..' / Path(image_link)).as_posix()
        if attr_list:
            attr_list = attr_list.replace('{', '').replace('}', '')
        else:
            attr_list = ''

        if not image_link.endswith(".svg"):
            image_element = rf'<img src="{image_link}" alt="{caption}" {attr_list}>'
        else:
            # load the entire SVG file and paste inline so that styling works properly
            absolute_path = Path(Path(file_path), Path(image_link)).resolve()
            image_element = absolute_path.read_text()
            # for now, we're not copying the attributes
            if attr_list:
                raise ValueError(f"Attributes on SVG images have not been implemented! See hooks.py. Received: '{attr_list}' while processing {file_path}")

        return (
            r'<figure class="figure-image">'
            rf'  {image_element}'
            rf'  <figcaption>{caption}</figcaption>'
            r'</figure>'
        )
    return modify_match

