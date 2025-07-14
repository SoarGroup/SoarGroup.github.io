-- Lua filter to extract index entries from HTML comments
-- Looks for comments like <!-- \index{term} --> and converts them to LaTeX index entries

local index_entries = {}

function extractIndexFromComment(comment_text)
    -- Match patterns like \index{term} in the comment
    local index_pattern = "\\index%s*{([^}]+)}"
    for term in comment_text:gmatch(index_pattern) do
        table.insert(index_entries, term)
        io.stderr:write("Index filter: Found index term: " .. term .. "\n")
    end
end

function processRawHTML(elem)
    -- Check if this is an HTML comment
    local comment_pattern = "<!%-%-(.-)%-%->"
    for comment_content in elem.text:gmatch(comment_pattern) do
        extractIndexFromComment(comment_content)
    end

    -- Remove the HTML comment from the output (so it's invisible in HTML/PDF)
    return {}
end

function processDoc(doc)
    -- Convert collected index entries to LaTeX index commands
    -- Insert them at the beginning of the document
    for i, term in ipairs(index_entries) do
        local latex_index = "\\index{" .. term .. "}"
        table.insert(doc.blocks, i, pandoc.RawBlock("latex", latex_index))
        io.stderr:write("Index filter: Added LaTeX index entry: " .. latex_index .. "\n")
    end

    io.stderr:write("Index filter: Processed " .. #index_entries .. " index entries\n")

    return doc
end

return {
    {
        RawInline = function(elem)
            if elem.format == "html" then
                return processRawHTML(elem)
            end
        end,
        RawBlock = function(elem)
            if elem.format == "html" then
                return processRawHTML(elem)
            end
        end
    },
    {
        Pandoc = processDoc
    }
}
