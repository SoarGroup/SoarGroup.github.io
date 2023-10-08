#!/bin/sh

for file in *.ps; do
    inkscape "$file" --export-plain-svg --export-type=svg --export-filename="test/${file%.*}.svg" --export-area-drawing
done
