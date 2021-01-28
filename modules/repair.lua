local _, aLie = ...

local function getGBLimit()
    local amount = GetGuildBankWithdrawMoney()
    local guildBankMoney = GetGuildBankMoney()
    if ( amount == -1 ) then
        amount = guildBankMoney
    else
        amount = min(amount, guildBankMoney)
    end
    return amount
end

local function format_money(money)
    local iconSize = 12
    local goldicon = format("\124TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:1:0\124t", iconSize, iconSize)
    local silvericon = format("\124TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:1:0\124t", iconSize, iconSize)
    local coppericon = format("\124TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:1:0\124t", iconSize, iconSize)

    local moneystring = ''
    local g,s,c

    g=floor(money/10000)
    s=floor((money-(g*10000))/100)
    c=money-s*100-g*10000

    if(money > 0) then
        if(g>0) then
            moneystring = format("%s%s",g,goldicon)
        end
        if(s>0) then
            moneystring = format("%s%s",s,silvericon)
        end
        if(c>0) then
            moneystring = format("%s%s",c,coppericon)
        end
    else
        moneystring = format("%s%s",'0',coppericon)
    end

    if(money < 0) then
        moneystring = format("-%s",moneystring)
    end

    return moneystring
end

local function onMerchant()
    if not aLieDB.Repair then return end

    if(CanMerchantRepair()) then
        local m = GetMoney()
        local r = GetRepairAllCost()
        local gbr = aLieDB.GuildbankRepair and CanGuildBankRepair()

        if(r > 0 and (m > r or gbr)) then
            local money = format_money(r)
            if(gbr) then
                if(getGBLimit() >= r) then
                    RepairAllItems(1)
                    addon:Print("Repair costs: " .. money)
                else
                    if(m > r) then
                        RepairAllItems()
                        aLie:l('repaircost' .. money)
                    else
                        aLie:l("c|ff0000 Guild allowance is not enough|r")
                    end
                end
            else
                RepairAllItems()
                aLie:l('Repair costs: '.. money)
            end
        end
    end
end

aLie:RegisterModule(
    "Repair",
    function()
        aLie:RegisterCallback("MERCHANT_SHOW", onMerchant)
    end
)
