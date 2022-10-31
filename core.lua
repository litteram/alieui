local A, ns = ...
ns.L = {}
local L = ns.L

function L.copyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[L.copyTable(orig_key)] = L.copyTable(orig_value)
        end
        setmetatable(copy, L.copyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function L:RegisterCallback(event, callback, ...)
    if callback == nil then print("callback for "..event.." is nil!") end
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        function self.eventFrame:OnEvent(event, ...)
            for callback, args in next, self.callbacks[event] do
                callback(args, event, ...)
            end
        end
        self.eventFrame:SetScript("OnEvent", self.eventFrame.OnEvent)
    end
    if not self.eventFrame.callbacks then self.eventFrame.callbacks = {} end
    if not self.eventFrame.callbacks[event] then self.eventFrame.callbacks[event] = {} end

    self.eventFrame.callbacks[event][callback] = {...}
    self.eventFrame:RegisterEvent(event)
end

function L:CallElementFunction(element, func, ...)
    if element and func and element[func] then
        element[func](element, ...)
    end
end