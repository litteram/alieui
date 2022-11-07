local A, ns = ...
local L = ns.L

local function btngen(prefix)
    local t = {}
    for i = 1, 12, 1 do
        t[i] = _G[prefix .. i]
    end
    return t
end


local function init()
    L:CreateButtonFrameFader(MainMenuBar, btngen("ActionButton"))

    if _G["MultiBarBottomLeft"] then
        L:CreateButtonFrameFader(MultiBarBottomLeft, btngen("MultiBarBottomLeftButton"))
    end

    if _G["MultiBarBottomRight"] then
        L:CreateButtonFrameFader(MultiBarBottomRight, btngen("MultiBarBottomRightButton"))
    end

    if _G["MultiBarRight"] then
        L:CreateButtonFrameFader(MultiBarRight, btngen("MultiBarRightButton"))
    end

    if _G["MultiBarLeft"] then
        L:CreateButtonFrameFader(MultiBarLeft, btngen("MultiBarLeftButton"))
    end
end

L:RegisterCallback('PLAYER_ENTERING_WORLD', init)
