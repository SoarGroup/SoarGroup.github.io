# Run this file from the root directory of this repository, otherwise
# the template.tex file path does not match.
mkdir output

pandoc \
    --pdf-engine=lualatex \
    --listings \
    --number-sections \
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
    --lua-filter=docs/soar_manual/path_filter.lua \
    -V geometry:"left=3cm, top=2.5cm, right=3cm, bottom=3cm" \
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

rm output/cli.tex
