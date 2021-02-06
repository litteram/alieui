local A, ns = ...

local function combatTextSetup()
    SetCVar("floatingCombatTextCombatDamage", 1)
    SetCVar("floatingCombatTextCombatHealing", 1)

    local font, size, _ = CombatTextFont:GetFont()

    COMBAT_TEXT_HEIGHT = size
    COMBAT_TEXT_CRIT_MAXHEIGHT = size*1
    COMBAT_TEXT_CRIT_MINHEIGHT = size*1
    COMBAT_TEXT_SCROLLSPEED = 2.5
    COMBAT_TEXT_Y_SCALE = 0.5
end

ns.L:RegisterModule("combatTextTweaks", combatTextSetup)
