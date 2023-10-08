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

return {
    {
        Link = removeFilePathFromLink
    }
}
