#!/bin/sh
set -e

# Run this file from the root directory of this repository, otherwise
# the template.tex file path does not match.
mkdir -p output

# Ensure optional LaTeX packages the template relies on are installed.
# In the pandoc/latex docker image these are not present by default.
if command -v tlmgr >/dev/null 2>&1; then
    tlmgr install newunicodechar >/dev/null 2>&1 || true
fi

# Resolve Soar version: prefer $SOAR_VERSION env var, else read from mkdocs.yml.
if [ -z "$SOAR_VERSION" ]; then
    SOAR_VERSION=$(sed -n 's/^ *soar_version: *//p' mkdocs.yml | head -n1 | tr -d '"' | tr -d "'")
fi
echo "Building manual for Soar version: $SOAR_VERSION"

# Stage manual sources with {{soar_version}} (and {{ soar_version }}) substituted,
# since the pandoc PDF pipeline does not run mkdocs' macro plugin.
STAGE=output/manual_src
rm -rf "$STAGE"
mkdir -p "$STAGE"
for f in docs/soar_manual/*.md; do
    sed -e "s/{{ *soar_version *}}/$SOAR_VERSION/g" "$f" > "$STAGE/$(basename "$f")"
done

pandoc \
    --pdf-engine=lualatex \
    --listings \
    --number-sections \
    --columns=200 \
    --lua-filter=docs/soar_manual/path_filter.lua \
    docs/reference/cli/cmd_*.md \
    --shift-heading-level-by=1 \
    -o output/cli.tex

pandoc \
    --pdf-engine=lualatex \
    --resource-path=docs/soar_manual/ \
    --template=docs/soar_manual/template.tex \
    --listings \
    --number-sections \
    --columns=200 \
    --lua-filter=docs/soar_manual/path_filter.lua \
    -V geometry:"left=3cm, top=2.5cm, right=3cm, bottom=3cm" \
    "$STAGE/01_Introduction.md" \
    "$STAGE/02_TheSoarArchitecture.md" \
    "$STAGE/03_SyntaxOfSoarPrograms.md" \
    "$STAGE/04_ProceduralKnowledgeLearning.md" \
    "$STAGE/05_ReinforcementLearning.md" \
    "$STAGE/06_SemanticMemory.md" \
    "$STAGE/07_EpisodicMemory.md" \
    "$STAGE/08_SpatialVisualSystem.md" \
    "$STAGE/09_SoarUserInterface.md" \
    output/cli.tex \
    -o output/SoarManual.pdf

rm -f output/cli.tex
rm -rf "$STAGE"
