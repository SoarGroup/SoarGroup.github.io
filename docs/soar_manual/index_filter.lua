-- Lua filter to extract index entries from HTML comments
-- Looks for comments like <!-- \index{term} --> and converts them to LaTeX index entries

function extractAndReplaceIndexFromComment(elem)
    if elem.format == "html" then
        -- Check if this is an HTML comment containing index entries
        local comment_pattern = "<!%-%-(.-)%-%->"
        local comment_content = elem.text:match(comment_pattern)
        if comment_content then
            io.stderr:write("Index filter: Processing HTML comment: " .. elem.text .. "\n")
            
            -- Extract all index terms from this comment
            local index_commands = {}
            local index_pattern = "\\index%s*{([^}]+)}"
            for term in comment_content:gmatch(index_pattern) do
                local latex_index = "\\index{" .. term .. "}"
                table.insert(index_commands, latex_index)
                io.stderr:write("Index filter: Found index term: " .. term .. "\n")
            end
            
            -- If we found index commands, replace the HTML comment with LaTeX index commands
            if #index_commands > 0 then
                local combined_latex = table.concat(index_commands, "")
                io.stderr:write("Index filter: Replacing HTML comment with: " .. combined_latex .. "\n")
                return pandoc.RawInline("latex", combined_latex)
            end
            
            -- If no index commands found, just remove the comment
            return {}
        end
    end
    return elem
end

function processDoc(doc)
    io.stderr:write("Index filter: Document processing completed\n")
    return doc
end

return {
    {
        RawInline = extractAndReplaceIndexFromComment,
        RawBlock = extractAndReplaceIndexFromComment
    },
    {
        Pandoc = processDoc
    }
}
