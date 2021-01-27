local A, aLie = ...

local GetCVarBool = _G.GetCVarBool
local GetNumLootItems = _G.GetNumLootItems
local GetTime = _G.GetTime
local IsModifiedClick = _G.IsModifiedClick
local LootSlot = _G.LootSlot

local lootDelay = 0
local function fastLoot()
    if not aLieDB.FastLoot then return end

    if GetTime() - lootDelay >= 0.3 then
        lootDelay = GetTime()
        if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end

            lootDelay = GetTime()
        end
    end
end

aLie:RegisterModule(
    "FastLoot",
    function()
        aLie:RegisterCallback("LOOT_READY", fastLoot)
    end
)
