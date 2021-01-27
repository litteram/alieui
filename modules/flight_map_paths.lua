local A, aLie = ...

local function addonLoaded(evt)
    if not aLieDB.FlightPaths then return end

    local hooked = 0
    TaxiFrame:HookScript("OnShow", function()
        local i = 1
        local button = _G["TaxiButton"..i]
        while (button) do
            button:SetShown(true)
            if (i > hooked) then
                hooked = hooked + 1
                button.Hide = button.Show
            end
            i = i + 1
            button = _G["TaxiButton"..i]
        end
    end)


    TaxiFrame:HookScript("OnHide", function()
        local i = 1
        local button = _G["TaxiButton"..i]
        while (button) do
            button:SetShown(false)
            i = i + 1
            button = _G["TaxiButton"..i]
        end
    end)
end

aLie:RegisterModule("FlightMapPaths", addonLoaded)
