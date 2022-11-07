local A, ns = ...

local LOOT_DELAY = 0.5
local epoch = 0
local function onLootReady()
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        if (GetTime() - epoch) >= LOOT_DELAY then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
            epoch = GetTime()
        end
    end
end

ns.L:RegisterCallback('LOOT_READY', onLootReady)
