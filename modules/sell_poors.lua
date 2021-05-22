
-- rSellPoor: core
-- zork, 2018

-----------------------------
-- Variables
-----------------------------

local A, ns = ...


-----------------------------
-- Functions
-----------------------------

local stop = true
local list = {}

local function sellGray()
    if stop then return end
    for bag=0,4 do
        for slot=0,GetContainerNumSlots(bag) do
            if stop then return end
            local link = GetContainerItemLink(bag, slot)
            if link and select(3, GetItemInfo(link)) == 0 and not list["b"..bag.."s"..slot] then
                --print(A,"selling",link,"bag",bag,"slot",slot)
                list["b"..bag.."s"..slot] = true
                UseContainerItem(bag, slot)
                C_Timer.After(0.1, sellGray)
                return
            end
        end
    end
end

local function onEvent(self,event)
    if not ns.L.db.global.sellPoors then return end

    if event == "MERCHANT_SHOW" then
        stop = false
        wipe(list)
        sellGray()
    elseif event == "MERCHANT_CLOSED" then
        stop = true
    end
end

local function setup()
    ns.L:RegisterCallback("MERCHANT_SHOW", onEvent)
    ns.L:RegisterCallback("MERCHANT_CLOSED", onEvent)
end

ns.L:RegisterModule("sellPoors", setup)
