local _, ns = ...

local PlayerFrame = _G["PlayerFrame"]
local TargetFrame = _G["TargetFrame"]
local FocusFrame = _G["FocusFrame"]

local cfg = {
    player = {"CENTER", UIParent, "CENTER", -160, -300},
    target = {"CENTER", UIParent, "CENTER", 160, -300},
    focus = {"CENTER", UIParent, "CENTER", 400, -300},
}

local function onLogin()
    PlayerFrame:ClearAllPoints()
    PlayerFrame:SetPoint(unpack(cfg.player))
    PlayerFrame:SetUserPlaced(true)

    TargetFrame:ClearAllPoints()
    TargetFrame:SetPoint(unpack(cfg.target))
    TargetFrame:SetUserPlaced(true)

    FocusFrame:ClearAllPoints()
    FocusFrame:SetPoint(unpack(cfg.focus))
    FocusFrame:SetUserPlaced(true)
end

local function onLogout()
    PlayerFrame:SetUserPlaced(false)
    TargetFrame:SetUserPlaced(false)
    FocusFrame:SetUserPlaced(false)
end

local function setup(evt)
    ns.L:RegisterCallback("VARIABLES_LOADED", onLogin)
    ns.L:RegisterCallback("PLAYER_LOGOUT", onLogout)
end

ns.L:RegisterModule("moveDefaultUF", setup)
