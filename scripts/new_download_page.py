# Generates a new download page and adds it to navigation
# Usage: python scripts/new_download_page.py <parent> <title>
# where <parent> is one of "agent_development_tools", "agents", "domains", "examples_and_unsupported"

from pathlib import Path
import sys
from string import Template

PROJECT_DIR = Path(__file__).parent.parent

DOWNLOADS_DIR = PROJECT_DIR / "docs" / "downloads"

MKDOCS_YML = PROJECT_DIR / "mkdocs.yml"

SECTIONS = ["agent_development_tools", "agents", "domains", "examples_and_unsupported"]

DOWNLOAD_TEMPLATE = Template(
    """---
Tags:
    - TODO
---

# $title

TODO: description

## Environment Properties

*   TODO (not for agents)

## External Environment

None TODO (agents only)

## Soar Capabilities

TODO

## Download Links

*   [TODO](https://github.com/SoarGroup/website-downloads/raw/main/$parent/TODO)

## Associated Agents

None TODO (not for agents)

## Default Rules

None TODO (agents only)

## Documentation

TODO

## Associated Publications

None
*   TODO

## Developers

John Laird TODO

## Soar Versions

TODO
*   Soar 8
*   Soar 9

## Language

TODO (not for agents)

## Project Type

VisualSoar TODO (agents only)
"""
)


def name_to_file_name(name: str) -> str:
    return name.lower().replace(" ", "_") + ".md"


def main(parent: str, title: str):
    # First check that that we are able to make all of the file changes
    # we need to

    if parent not in SECTIONS:
        print(f"Invalid parent; must be one of {SECTIONS}")
        return
    parent_dir = DOWNLOADS_DIR / parent
    index_file = parent_dir / "index.md"
    if not index_file.exists():
        raise FileNotFoundError(f"Parent directory {parent_dir} does not exist")

    new_file_name = name_to_file_name(title)
    new_file_path = parent_dir / new_file_name
    if new_file_path.exists():
        print(f"File {new_file_path} already exists")
        return
    new_file_contents = DOWNLOAD_TEMPLATE.substitute(title=title, parent=parent)

    with open(MKDOCS_YML, "r") as f:
        lines = f.readlines()
    index_line = None
    num_leading_spaces = -1
    expected_parent_line = f"- downloads/{parent}/index.md"
    for i, line in enumerate(lines):
        if line.strip() == expected_parent_line:
            index_line = i
            num_leading_spaces = len(line) - len(line.lstrip())
            break
    line_to_insert = f"{' ' * num_leading_spaces}- {title}: downloads/{parent}/{new_file_name}\n"
    line_inserted = False
    for i in range(index_line + 1, len(lines)):
        if len(lines[i]) - len(lines[i].lstrip()) < num_leading_spaces:
            lines.insert(i, line_to_insert)
            line_inserted = True
            break
    # if we didn't insert the line, then we must have reached the end of the file. Insert there.
    if not line_inserted:
        lines.append(line_to_insert)

    # then do the actual edits

    print(f"Adding file {new_file_path}")
    with open(new_file_path, "w") as f:
        f.write(new_file_contents)

    print(f"Adding link to {index_file}")
    with open(index_file, "a") as f:
        f.write(f"*   [{title}](./{new_file_name})\n")

    print(f"Adding to mkdocs.yml")
    with open(MKDOCS_YML, "w") as f:
        f.write("".join(lines))


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <parent> <title>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])
