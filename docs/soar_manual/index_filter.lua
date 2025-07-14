-- Lua filter to extract index entries from HTML comments
-- Looks for comments like <!-- \index{term} --> and converts them to LaTeX index entries

function extractAndReplaceIndexFromInline(elem)
    if elem.format == "html" then
        -- Check if this is an HTML comment containing index entries
        local comment_pattern = "<!%-%-(.-)%-%->"
        local comment_content = elem.text:match(comment_pattern)
        if comment_content then
            io.stderr:write("Index filter: Processing HTML inline comment: " .. elem.text .. "\n")

            -- Check if this comment contains \index commands
            if comment_content:match("\\index") then
                io.stderr:write("Index filter: Found \\index in inline comment: " .. comment_content .. "\n")

                -- Extract all index terms from this comment
                local index_commands = {}
                local index_pattern = "\\index%s*{([^}]+)}"
                for term in comment_content:gmatch(index_pattern) do
                    local latex_index = "\\index{" .. term .. "}"
                    table.insert(index_commands, latex_index)
                    io.stderr:write("Index filter: Found index term: " .. term .. "\n")
                end

                -- If we found index commands, replace with inline LaTeX
                if #index_commands > 0 then
                    local combined_latex = table.concat(index_commands, " ")
                    io.stderr:write("Index filter: Replacing inline comment with: " .. combined_latex .. "\n")
                    return pandoc.RawInline("latex", combined_latex)
                end
            else
                io.stderr:write("Index filter: Inline comment does not contain \\index, ignoring: " .. comment_content .. "\n")
            end

            -- If no index commands found, just remove the comment
            return {}
        end
    end
    return elem
end

function extractAndReplaceIndexFromBlock(elem)
    if elem.format == "html" then
        -- Check if this is an HTML comment containing index entries
        local comment_pattern = "<!%-%-(.-)%-%->"
        local comment_content = elem.text:match(comment_pattern)
        if comment_content then
            io.stderr:write("Index filter: Processing HTML block comment: " .. elem.text .. "\n")

            -- Check if this comment contains \index commands
            if comment_content:match("\\index") then
                io.stderr:write("Index filter: Found \\index in block comment: " .. comment_content .. "\n")

                -- Extract all index terms from this comment
                local index_commands = {}
                local index_pattern = "\\index%s*{([^}]+)}"
                for term in comment_content:gmatch(index_pattern) do
                    local latex_index = "\\index{" .. term .. "}"
                    table.insert(index_commands, latex_index)
                    io.stderr:write("Index filter: Found index term: " .. term .. "\n")
                end

                -- If we found index commands, replace with block LaTeX
                if #index_commands > 0 then
                    local combined_latex = table.concat(index_commands, "\n")
                    io.stderr:write("Index filter: Replacing block comment with: " .. combined_latex .. "\n")
                    return pandoc.RawBlock("latex", combined_latex)
                end
            else
                io.stderr:write("Index filter: Block comment does not contain \\index, ignoring: " .. comment_content .. "\n")
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
        RawInline = extractAndReplaceIndexFromInline,
        RawBlock = extractAndReplaceIndexFromBlock
    },
    {
        Pandoc = processDoc
    }
}
