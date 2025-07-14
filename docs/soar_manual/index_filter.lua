-- Pandoc Lua filter to extract LaTeX index commands from HTML comments
-- This allows index entries to be hidden from MkDocs while being processed for PDF output

function extractIndexFromComments(elem)
    if elem.tag == "RawInline" and elem.format == "html" then
        local comment = elem.text
        -- Match HTML comments containing \index commands
        local index_cmd = comment:match("<!%-%-.-%\\index{(.-)}.-->")
        if index_cmd then
            -- Return LaTeX raw inline instead of HTML comment
            return pandoc.RawInline("latex", "\\index{" .. index_cmd .. "}")
        end
        -- Match full \index{...} commands in comments
        local full_index = comment:match("<!%-%-.-(%\\index{.-}).--->")
        if full_index then
            return pandoc.RawInline("latex", full_index)
        end
    end
    return elem
end

return {
    {
        RawInline = extractIndexFromComments
    }
}
