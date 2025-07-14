-- Simple filter to convert HTML comments with \index commands to LaTeX

function processBlock(block)
    if block.tag == "RawBlock" and block.format == "html" then
        local text = block.text
        -- Check if this is an HTML comment with \index
        local index_match = text:match("^<!%-%-%s*\\index{(.-)}.-->$")
        if index_match then
            return pandoc.RawBlock("latex", "\\index{" .. index_match .. "}")
        end
    end
    return block
end

function processInline(inline)
    if inline.tag == "RawInline" and inline.format == "html" then
        local text = inline.text
        -- Check if this is an HTML comment with \index
        local index_match = text:match("^<!%-%-%s*\\index{(.-)}.-->$")
        if index_match then
            return pandoc.RawInline("latex", "\\index{" .. index_match .. "}")
        end
    end
    return inline
end

return {
    { RawBlock = processBlock, RawInline = processInline }
}
