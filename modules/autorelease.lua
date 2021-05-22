local _, ns = ...

local function HasSoulstone()
    local options = GetSortedSelfResurrectOptions()
    return options and options[1] and options[1].name
end

local function onDeathDialog(self)
    if not ns.L.db.global.autorelease then return end
    local frame = self

    local function release()
        -- death log
        if frame.button4 then
            frame.button4:Click()
        end

        if C_PvP.IsActiveBattlefield() and not IsActiveBattlefieldArena() then
            if not HasSoulstone() then
                frame.button1:Click()
            end
        end
    end

    C_Timer.After(0.5, release)
end

local function setup()
    hooksecurefunc(StaticPopupDialogs["DEATH"], "OnShow", onDeathDialog)
end

ns.L:RegisterModule('autorelease', setup)
