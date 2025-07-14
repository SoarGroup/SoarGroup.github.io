-- Lua filter to extract index entries from HTML comments
-- Looks for comments like <!-- \index{term} --> and converts them to LaTeX index entries

local index_entries = {}

function extractIndexFromText(text)
    if not text then
        return
    end

    -- Match HTML comments containing \index{...} patterns
    local comment_pattern = "<!%-%-(.-)%-%->"
    for comment_content in text:gmatch(comment_pattern) do
        -- Look for \index{term} within the comment
        local index_pattern = "\\index%s*{([^}]+)}"
        for term in comment_content:gmatch(index_pattern) do
            table.insert(index_entries, term)
            io.stderr:write("Index filter: Found index term: " .. term .. "\n")
        end
    end
end

function processAnyElement(elem)
    -- Check if element has text content
    if elem.text then
        extractIndexFromText(elem.text)
    end

    -- Check if element has content (for containers)
    if elem.content then
        for _, child in ipairs(elem.content) do
            if child.text then
                extractIndexFromText(child.text)
            end
        end
    end

    return elem
end

function processDoc(doc)
    -- Convert collected index entries to LaTeX index commands
    -- Insert them at the beginning of the document
    local new_blocks = {}

    for _, term in ipairs(index_entries) do
        local latex_index = "\\index{" .. term .. "}"
        table.insert(new_blocks, pandoc.RawBlock("latex", latex_index))
        io.stderr:write("Index filter: Added LaTeX index entry: " .. latex_index .. "\n")
    end

    -- Add original blocks after index entries
    for _, block in ipairs(doc.blocks) do
        table.insert(new_blocks, block)
    end

    doc.blocks = new_blocks
    io.stderr:write("Index filter: Processed " .. #index_entries .. " index entries\n")

    return doc
end

-- Walk through all elements to find HTML comments
return {
    {
        Str = processAnyElement,
        RawInline = processAnyElement,
        RawBlock = processAnyElement,
        Code = processAnyElement,
        CodeBlock = processAnyElement,
        Para = processAnyElement,
        Plain = processAnyElement
    },
    {
        Pandoc = processDoc
    }
}
