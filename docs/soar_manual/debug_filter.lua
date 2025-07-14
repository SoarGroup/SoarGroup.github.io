-- Debug filter to see what Pandoc is actually processing

function debug_all(elem)
    if elem.tag == "RawInline" or elem.tag == "RawBlock" then
        io.stderr:write("Found " .. elem.tag .. " with format: " .. (elem.format or "nil") .. " and text: " .. (elem.text or "nil") .. "\n")
    end
    if elem.tag == "Str" and elem.text and elem.text:match("index") then
        io.stderr:write("Found Str with index-related text: " .. elem.text .. "\n")
    end
    return elem
end

return {
    {
        RawInline = debug_all,
        RawBlock = debug_all,
        Str = debug_all,
        Para = debug_all
    }
}
