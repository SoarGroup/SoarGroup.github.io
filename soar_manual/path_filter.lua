-- Changes links between markdown files that are added to manual PDF so that they
-- point to the correct section in the PDF rather than the file path.
function DebugMessage(message)
    io.stderr:write("Debug: " .. message .. "\n")
end

function removeFilePathFromLink(elem)
    if elem.tag == "Link" then
        local url = elem.target
        local index = url:find("#")

        if index then
            local sectionReference = url:sub(index)
            elem.target = sectionReference
            DebugMessage("UPDT: " .. url .. " -> " .. sectionReference)
        else
            DebugMessage("SKIP: " .. url)
        end
    end
    return elem
end

-- pandoc's --listings emits inline code as \passthrough{\lstinline!...!}.
-- \lstinline can't read its argument verbatim inside another macro's argument
-- when the content contains `$` (TeX enters math mode before \lstinline sees
-- it). For inline code that contains a literal `$`, bypass listings and emit
-- \texttt{...} with `$` escaped. All other inline code keeps the original
-- listings rendering (so line-breaking and styling are preserved).
local function latexEscapeDollarOnly(s)
    -- Content may legitimately contain backslashes, braces, etc. — but in
    -- practice Soar/CLI inline code with `$` is plain ASCII. Escape the bare
    -- minimum to keep TeX happy.
    s = s:gsub("\\", "\\textbackslash{}")
    s = s:gsub("([%%#&_{}])", "\\%1")
    s = s:gsub("%$", "\\$")
    s = s:gsub("~", "\\textasciitilde{}")
    s = s:gsub("%^", "\\textasciicircum{}")
    return s
end

function escapeInlineCode(elem)
    if elem.tag == "Code" and elem.text:find("%$") then
        return pandoc.RawInline("latex", "\\texttt{" .. latexEscapeDollarOnly(elem.text) .. "}")
    end
    return elem
end

-- Drop MkDocs Material-specific raw HTML that only exists for web styling
-- (grid cards, admonition wrappers, anchor-only <p>/<a> tags etc.). The
-- content *between* the opening and closing tags is already separate markdown
-- and is rendered normally; we only need to suppress the standalone HTML
-- tags so pandoc doesn't emit them literally (or drop the whole block) in
-- the PDF. Web rendering is unaffected because this filter only runs for
-- the PDF build.
local function stripWebOnlyRawHtml(elem)
    if elem.format ~= "html" then
        return elem
    end
    local t = elem.text
    -- Match a single opening tag like `<div class="grid cards" markdown>`,
    -- a bare closing `</div>`, or anchor-only `<p id="..."/>`/`<a name="..."/>`.
    -- These carry no rendered content in the PDF.
    if t:match('^%s*<div[^>]*>%s*$')
        or t:match('^%s*</div>%s*$')
        or t:match('^%s*<p%s+id="[^"]*"%s*/?>%s*</?p?>?%s*$')
        or t:match('^%s*<a%s+name="[^"]*"%s*/?>%s*</?a?>?%s*$') then
        return {}
    end
    return elem
end

return {
    {
        Code = escapeInlineCode,
        Link = removeFilePathFromLink,
        RawBlock = stripWebOnlyRawHtml,
    }
}
