local _, aLie = ...

local function ScreenshotAchi()
    if aLieDB.ScreenshotAchi then
        C_Timer.After(1, Screenshot)
    end
end

aLie:RegisterModule(
    "ScreenshotAchi",
    function()
        aLie:RegisterCallback("ACHIEVEMENT_EARNED", ScreenshotAchi)
    end
)
