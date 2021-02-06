local _, ns = ...

function aLie:CopyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[aLie:CopyTable(orig_key)] = aLie:CopyTable(orig_value)
        end
        setmetatable(copy, aLie:CopyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
