-- Comprehensive filter to catch HTML comments with index commands

function processAny(elem)
    -- Handle any element that might contain our HTML comments
    local text = ""

    if elem.tag == "RawBlock" or elem.tag == "RawInline" then
        text = elem.text or ""
    elseif elem.tag == "Str" then
        text = elem.text or ""
    elseif elem.tag == "Para" then
        text = pandoc.utils.stringify(elem)
    end

    -- Look for HTML comments with index commands anywhere in the text
    if text and text:match("<!%-%-%s*\\index{.-}%s*-->") then
        -- Found an index comment - extract all index commands
        local index_commands = {}
        for index_cmd in text:gmatch("<!%-%-%s*(\\index{.-})%s*-->") do
            table.insert(index_commands, pandoc.RawInline("latex", index_cmd))
        end

        -- If we found any, return them
        if #index_commands > 0 then
            if #index_commands == 1 then
                return index_commands[1]
            else
                return index_commands
            end
        end
    end

    return elem
end

-- Also try a document-level approach to insert some test index entries
function processDocument(doc)
    -- Add a test index entry at the very beginning
    table.insert(doc.blocks, 1, pandoc.RawBlock("latex", "\\index{test-entry}"))
    return doc
end

return {
    {
        RawBlock = processAny,
        RawInline = processAny,
        Str = processAny,
        Para = processAny,
        Pandoc = processDocument
    }
}
