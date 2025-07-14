-- Simple Pandoc Lua filter to add index entries
-- For now, let's just add some basic index entries manually

function addIndexEntries(meta)
    -- This function runs once per document
    return meta
end

function processDocument(doc)
    -- Add some basic index entries at the beginning of the document
    local index_entries = {
        pandoc.RawBlock("latex", "\\index{chunking}"),
        pandoc.RawBlock("latex", "\\index{chunk}"),
        pandoc.RawBlock("latex", "\\index{result}"),
        pandoc.RawBlock("latex", "\\index{subgoal}"),
        pandoc.RawBlock("latex", "\\index{instantiation}"),
        pandoc.RawBlock("latex", "\\index{chunking!backtracing}"),
        pandoc.RawBlock("latex", "\\index{singleton}"),
        pandoc.RawBlock("latex", "\\index{chunking!explanation-based behavior summarization}")
    }

    -- Insert index entries at the beginning
    for i = #index_entries, 1, -1 do
        table.insert(doc.blocks, 1, index_entries[i])
    end

    return doc
end

return {
    {
        Meta = addIndexEntries,
        Pandoc = processDocument
    }
}
