local A, aLie = ...

local lock = false
local function setUIScale(self, evt)
    if lock then return true end
    if not aLieDB.UIScale then return true end

    if not InCombatLockdown() then
        local scale = 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
        if scale < .64 then
            UIParent:SetScale(scale)
        else
            SetCVar("uiScale", scale)
        end

        lock = true
    end
end

aLie:RegisterModule(
    "UIScale",
    function()
        aLie:RegisterCallback("VARIABLES_LOADED", setUIScale)
        aLie:RegisterCallback("UI_SCALE_CHANGED", setUIScale)
    end
)
