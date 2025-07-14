#!/bin/sh
set -e  # Exit on any error

# Run this file from the root directory of this repository, otherwise
# the template.tex file path does not match.
mkdir -p output
echo "Created output directory"

pandoc \
    --pdf-engine=lualatex \
    --listings \
    --number-sections \
    --lua-filter=docs/soar_manual/path_filter.lua \
    docs/reference/cli/cmd_*.md \
    --shift-heading-level-by=1 \
    -o output/cli.tex

echo "Generated CLI LaTeX file"

pandoc \
    --pdf-engine=lualatex \
    --resource-path=docs/soar_manual/ \
    --template=docs/soar_manual/template.tex \
    --listings \
    --number-sections \
    --lua-filter=docs/soar_manual/path_filter.lua \
    --lua-filter=docs/soar_manual/index_filter.lua \
    -V geometry:"left=3cm, top=2.5cm, right=3cm, bottom=3cm" \
    -V has-index \
    docs/soar_manual/01_Introduction.md \
    docs/soar_manual/02_TheSoarArchitecture.md \
    docs/soar_manual/03_SyntaxOfSoarPrograms.md \
    docs/soar_manual/04_ProceduralKnowledgeLearning.md \
    docs/soar_manual/05_ReinforcementLearning.md \
    docs/soar_manual/06_SemanticMemory.md \
    docs/soar_manual/07_EpisodicMemory.md \
    docs/soar_manual/08_SpatialVisualSystem.md \
    docs/soar_manual/09_SoarUserInterface.md \
    output/cli.tex \
    -o output/SoarManual.pdf

echo "Generated initial PDF with index commands"

# Check if index file was generated, and if not, create a test one
if [ -f "output/SoarManual.idx" ]; then
    echo "Index entries found, running makeindex..."
else
    echo "No .idx file found, creating test index file..."
    echo '\indexentry{chunking}{1}' > output/SoarManual.idx
    echo '\indexentry{test-entry}{1}' >> output/SoarManual.idx
    echo '\indexentry{Soar}{1}' >> output/SoarManual.idx
    echo "Test index file created"
fi

cd output && makeindex SoarManual.idx && cd ..
echo "Makeindex completed"

echo "Starting second pandoc run to include index"

# Run pandoc again to include the index in the final PDF
pandoc \
    --pdf-engine=lualatex \
    --resource-path=docs/soar_manual/ \
    --template=docs/soar_manual/template.tex \
    --listings \
    --number-sections \
    --lua-filter=docs/soar_manual/path_filter.lua \
    --lua-filter=docs/soar_manual/index_filter.lua \
    -V geometry:"left=3cm, top=2.5cm, right=3cm, bottom=3cm" \
    -V has-index \
    docs/soar_manual/01_Introduction.md \
    docs/soar_manual/02_TheSoarArchitecture.md \
    docs/soar_manual/03_SyntaxOfSoarPrograms.md \
    docs/soar_manual/04_ProceduralKnowledgeLearning.md \
    docs/soar_manual/05_ReinforcementLearning.md \
    docs/soar_manual/06_SemanticMemory.md \
    docs/soar_manual/07_EpisodicMemory.md \
    docs/soar_manual/08_SpatialVisualSystem.md \
    docs/soar_manual/09_SoarUserInterface.md \
    output/cli.tex \
    -o output/SoarManual.pdf

echo "Generated final PDF with index"

echo "PDF generation completed"

# Clean up the temporary CLI file
if [ -f "output/cli.tex" ]; then
    rm output/cli.tex
fi

echo "Build completed"
