local _, ns = ...

local function ScreenshotAchi()
    if aLieDB.ScreenshotAchi then
        C_Timer.After(1, Screenshot)
    end
end

local function setup()
    ns.L:RegisterCallback("ACHIEVEMENT_EARNED", ScreenshotAchi)
end

ns.L:RegisterModule("screenshotAchi", setup)
