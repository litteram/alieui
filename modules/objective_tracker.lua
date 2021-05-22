local addOn, ns = ...
local L = ns.L

-----------------------------
-- Config
-----------------------------

local cfg = {
    scale = 1,
    point = { "RIGHT", -110, -30 },
    size = { 260, 500 },
    fader = {
        fadeInAlpha = 1,
        fadeInDuration = 0.3,
        fadeInSmooth = "OUT",
        fadeOutAlpha = 0,
        fadeOutDuration = 0.9,
        fadeOutSmooth = "OUT",
        fadeOutDelay = 0,
    },
}


-- Move the Objective Tracker
ObjectiveTrackerFrame:SetScale(cfg.scale)
ObjectiveTrackerFrame:ClearAllPoints()
ObjectiveTrackerFrame:SetPoint(unpack(cfg.point))
ObjectiveTrackerFrame:SetSize(unpack(cfg.size))

ObjectiveTrackerFrame:SetMovable(true)
ObjectiveTrackerFrame:SetUserPlaced(true)
ObjectiveTrackerFrame:SetClampedToScreen(true)

-----------------------------
-- Init
-----------------------------

local function setup()
    --frame fader
    ns:CreateFrameFader(ObjectiveTrackerFrame, cfg.fader)
end

L:RegisterModule('objectiveTracker', setup)
