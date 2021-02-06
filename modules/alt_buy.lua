local _, ns = ...
local L = ns.L

local function setup()
    local select = select

    local NEW_ITEM_VENDOR_STACK_BUY = ITEM_VENDOR_STACK_BUY
    ITEM_VENDOR_STACK_BUY = "|cffa9ff00"..NEW_ITEM_VENDOR_STACK_BUY.."|r" -- luacheck: ignore

    -- Alt-click to buy a stack.

    hooksecurefunc("MerchantItemButton_OnModifiedClick", function(self, ...)
        if IsAltKeyDown() then
            local numAvailable = select(5, GetMerchantItemInfo(self:GetID()))

            -- -1 means an item has unlimited supply.
            if numAvailable ~= -1 then
                BuyMerchantItem(self:GetID(), numAvailable)
            else
                BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
            end
        end
    end)

    -- Add a hint to the tooltip.

    local function IsMerchantButtonOver()
        return GetMouseFocus():GetName() and GetMouseFocus():GetName():find("MerchantItem%d")
    end

    GameTooltip:HookScript("OnTooltipSetItem", function(self)
        if MerchantFrame:IsShown() and IsMerchantButtonOver() then
            for i = 2, GameTooltip:NumLines() do
                local line = _G["GameTooltipTextLeft"..i]:GetText() or ""
                if line:find("<[sS]hift") then
                    GameTooltip:AddLine("|cff00ffcc<Alt-Click to buy a full stack>|r")
                end
            end
        end
    end)
end

L:RegisterModule('altbuy', setup)
