local A, ns = ...

local GetCVarBool = _G.GetCVarBool
local GetNumLootItems = _G.GetNumLootItems
local GetTime = _G.GetTime
local IsModifiedClick = _G.IsModifiedClick
local LootSlot = _G.LootSlot

local DEBOUNCE_INTERVAL = 0.3

local delay = 0
local LootFrame_OnEvent_default = LootFrame:GetScript("OnEvent")

-- Fast loot function
function fastLoot()
    if GetTime() - delay >= DEBOUNCE_INTERVAL then
        for i = GetNumLootItems(), 1, -1 do
            LootSlot(i)
        end
        delay = GetTime()
    end
end

function LootFrame_OnEvent_modified(...)
    local _, event = ...

    if event == "LOOT_READY" and ns.L.db.global.fastLoot and GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        fastLoot()
    else
        LootFrame_OnEvent_default(...)
    end
end



local function setup()
    LootFrame:SetScript("OnEvent", LootFrame_OnEvent_modified)
end

ns.L:RegisterModule("fastLoot", setup)
