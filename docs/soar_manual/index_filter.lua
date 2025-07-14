-- Pandoc Lua filter to extract LaTeX index commands
-- This allows index entries to be included in PDF output while being invisible in MkDocs

function processIndexCommands(elem)
    -- Handle RawInline and RawBlock elements with LaTeX format
    if elem.tag == "RawInline" and elem.format == "latex" then
        local text = elem.text or ""
        -- If it contains \index commands, pass them through
        if text:match("\\index{.-}") then
            return elem  -- Pass through as-is
        end
    end
    return elem
end

-- Convert standalone \index{} commands in text to raw LaTeX
function convertIndexToRaw(elem)
    if elem.tag == "Str" then
        local text = elem.text or ""
        -- If the entire string is just \index commands, convert to raw LaTeX
        if text:match("^\\index{.-}+$") then
            return pandoc.RawInline("latex", text)
        end
        -- If it contains \index commands mixed with other text, extract them
        if text:match("\\index{.-}") then
            local parts = {}
            local last_end = 1
            for index_cmd in text:gmatch("(\\index{.-})") do
                local start_pos, end_pos = text:find(index_cmd, last_end, true)
                if start_pos > last_end then
                    table.insert(parts, pandoc.Str(text:sub(last_end, start_pos - 1)))
                end
                table.insert(parts, pandoc.RawInline("latex", index_cmd))
                last_end = end_pos + 1
            end
            if last_end <= #text then
                table.insert(parts, pandoc.Str(text:sub(last_end)))
            end
            return parts
        end
    end
    return elem
end

return {
    {
        RawInline = processIndexCommands,
        Str = convertIndexToRaw
    }
}
