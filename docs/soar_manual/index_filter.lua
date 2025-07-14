-- Simple test filter to add index entries

function processDoc(doc)
    -- Insert multiple test index entries at the beginning
    table.insert(doc.blocks, 1, pandoc.RawBlock("latex", "\\index{chunking}"))
    table.insert(doc.blocks, 2, pandoc.RawBlock("latex", "\\index{test-entry}"))
    table.insert(doc.blocks, 3, pandoc.RawBlock("latex", "\\index{Soar}"))

    -- Also add some debug output
    io.stderr:write("Index filter: Added test index entries\n")

    return doc
end

return {
    {
        Pandoc = processDoc
    }
}
