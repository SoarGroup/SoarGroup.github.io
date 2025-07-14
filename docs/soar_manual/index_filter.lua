-- Pandoc Lua filter to extract LaTeX index commands from HTML comments
-- This allows index entries to be hidden from MkDocs while being processed for PDF output

function extractIndexFromComments(elem)
    -- Handle both RawInline and RawBlock elements
    if (elem.tag == "RawInline" or elem.tag == "RawBlock") and elem.format == "html" then
        local comment = elem.text
        -- Match HTML comments containing \index commands
        local index_cmd = comment:match("<!%-%-%s*\\index{(.-)}.-->")
        if index_cmd then
            -- Return LaTeX raw inline instead of HTML comment
            return pandoc.RawInline("latex", "\\index{" .. index_cmd .. "}")
        end
        -- Match full \index{...} commands in comments (allowing spaces)
        local full_index = comment:match("<!%-%-%s*(%\\index{.-})%s*-->")
        if full_index then
            return pandoc.RawInline("latex", full_index)
        end
    end
    return elem
end

return {
    {
        RawInline = extractIndexFromComments,
        RawBlock = extractIndexFromComments
    }
}
