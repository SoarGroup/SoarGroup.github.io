-- Pandoc Lua filter to extract LaTeX index commands from HTML comments
-- This allows index entries to be hidden from MkDocs while being processed for PDF output

function extractIndexFromComments(elem)
    -- Handle RawInline and RawBlock elements with any format
    if elem.tag == "RawInline" or elem.tag == "RawBlock" then
        local text = elem.text or ""
        -- Match HTML comments containing \index commands
        local index_cmd = text:match("<!%-%-%s*\\index{(.-)}.-->")
        if index_cmd then
            return pandoc.RawInline("latex", "\\index{" .. index_cmd .. "}")
        end
        -- Match full \index{...} commands in comments (allowing spaces)
        local full_index = text:match("<!%-%-%s*(%\\index{.-})%s*-->")
        if full_index then
            return pandoc.RawInline("latex", full_index)
        end
    end
    return elem
end

-- Also try to catch HTML comments that might be processed as plain text
function extractFromPlainText(elem)
    local text = ""
    if elem.tag == "Str" then
        text = elem.text or ""
    elseif elem.tag == "Para" then
        text = pandoc.utils.stringify(elem)
    end

    if text and text:match("<!%-%-%s*\\index{.-}%s*-->") then
        -- Replace HTML comments with LaTeX index commands
        local new_text = text:gsub("<!%-%-%s*(\\index{.-})%s*-->", "%1")
        if new_text ~= text then
            return pandoc.RawInline("latex", new_text)
        end
    end
    return elem
end

return {
    {
        RawInline = extractIndexFromComments,
        RawBlock = extractIndexFromComments,
        Str = extractFromPlainText,
        Para = extractFromPlainText
    }
}
