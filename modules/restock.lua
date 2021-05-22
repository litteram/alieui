local _, ns = ...
local L = ns.L

local buyList = {
    180817, -- Cypher of relocation
}

local function restock()
	local cost = 0
	for i=1, GetMerchantNumItems() do	--scan merchant's items for ones I need
		local item,_,price,stack,maxItems = GetMerchantItemInfo(i)
		if buyList[item] then
			local need = buyList[item].stock - GetItemCount(item)
			if not maxItems == -1 and need > maxItems then	--if not unlimited supply, and I need more than they have
				need = maxItems
			end
			if need > 0 then	--if I need something, then buy it
				local stillNeed = need
				local maxStack = GetMerchantItemMaxStack(i)
				while stillNeed > 0 do
					BuyMerchantItem(i, (stillNeed > maxStack and maxStack) or need)	--buy as many as I can or just what I need
					stillNeed = stillNeed - maxStack
				end
				--cost = cost + (price*need)	--tally my cost
				cost = cost + (price*(need/stack))	--tally my cost
			end
		end
	end
	if cost > 0 and db.details then
		print("|cffe6cc80VendorMaster:|r Items purchased for a total of:", GetCoinTextureString(cost))
	end
end


local function setup()
    L:RegisterCallback('MERCHANT_SHOW', restock)
end

L:RegisterModule('venari', setup)
