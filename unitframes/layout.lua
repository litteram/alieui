local name, ns = ...
local L = ns.L
local oUF = ns.oUF or oUF
local C = ns.db.unitframes

local _, class = UnitClass('player')

local CASTBAR_X_OFFSET = 0
local CASTBAR_Y_OFFSET = 2
local POWER_X_OFFSET = 0
local POWER_Y_OFFSET = 1
local CLASSPOWER_X_OFFSET = 0
local CLASSPOWER_Y_OFFSET = -8
local TEXT_Y_OFFSET = 6
local TEXT_X_OFFSET = 2
local CASTBAR_HEIGHT_RATIO = 2
local OOC_ALPHA = C.outofcombat_alpha or 0.1

-- Override some oUF.colors.power
-- is there a nicer way?
oUF.colors.power["COMBO_POINTS"] = {1, 0.1, 0.1}
oUF.colors.power["FOCUS"] = {1, 0.5, 0.25} -- why do we have to do this?

local createStatusbar = function(parent, tex, layer, height, width, r, g, b, alpha)
    local bar = CreateFrame("StatusBar", nil, parent)
    if height then
        bar:SetHeight(height)
    end
    if width then
        bar:SetWidth(width)
    end
    bar:SetStatusBarTexture(tex, layer or "ARTWORK")
    if (r and b and g and alpha) then
        bar:SetStatusBarColor(r, g, b, alpha)
    end
    return bar
end

local function EnterCombat(self)
    self:PlayReveal()
    oUF_aLiePet:PlayReveal()
end

local function LeaveCombat(self)
    local min, max = UnitHealth('player'), UnitHealthMax('player')
    if min ~= max or UnitCastingInfo("player") then return end
    self:PlayHide()
    oUF_aLiePet:PlayHide()
end

local function HealthUpdate(self)
    if UnitAffectingCombat('player') and self:GetAlpha() == 1 then return end

    local min, max = UnitHealth('player'), UnitHealthMax('player')

    if UnitAffectingCombat('player') then
        self:PlayReveal()
        oUF_aLiePet:PlayReveal()
    elseif min ~= max then
        self:PlayAlpha(OOC_ALPHA)
        oUF_aLiePet:PlayAlpha(OOC_ALPHA)
    else
        self:PlayHide()
        oUF_aLiePet:PlayHide()
    end
end

local function EnterVehicle(self)
    self:PlayAlpha(OOC_ALPHA)
    oUF_aLiePet:PlayAlpha(OOC_ALPHA)
end

local function ExitVehicle(self)
    HealthUpdate(self)
end

local function SpellStart(self)
    if not UnitAffectingCombat('player') or self:GetAlpha() == 0 then
        self:PlayAlpha(OOC_ALPHA)
    end
end

local function SpellFinish(self)
    if not UnitAffectingCombat('player') then
        self:PlayHide()
    end
end

local OnEnter = function(self)
    UnitFrame_OnEnter(self)
    if self.GroupRoleIndicator then
        if self.LFDTimer then self.LFDTimer:Cancel() end
        self.GroupRoleIndicator:PlayReveal()
    end
    self.Highlight:Show()
end

local OnLeave = function(self)
    UnitFrame_OnLeave(self)
    if self.GroupRoleIndicator then
        self.LFDTimer = C_Timer.NewTimer(1, function() self.GroupRoleIndicator:PlayHide() end)
    end
    self.Highlight:Hide()
end

local dropdown = CreateFrame('Frame', name .. 'DropDown', UIParent, 'UIDropDownMenuTemplate')

local function menu(self)
    dropdown:SetParent(self)
    return ToggleDropDownMenu(1, nil, dropdown, self:GetName(), -3, 0)
end

local init = function(self)
    local unit = self:GetParent().unit
    local menu, name, id

    if(not unit) then
        return
    end

    if(UnitIsUnit(unit, 'player')) then
        menu = 'SELF'
    elseif(UnitIsUnit(unit, 'vehicle')) then
        menu = 'VEHICLE'
    elseif(UnitIsUnit(unit, 'pet')) then
        menu = 'PET'
    elseif(UnitIsPlayer(unit)) then
        id = UnitInRaid(unit)
        if(id) then
            menu = 'RAID_PLAYER'
            name = GetRaidRosterInfo(id)
        elseif(UnitInParty(unit)) then
            menu = 'PARTY'
        else
            menu = 'PLAYER'
        end
    else
        menu = 'TARGET'
        name = RAID_TARGET_ICON
    end

    if (menu) then
        UnitPopup_ShowMenu(self, menu, unit, name, id)
    end
end

UIDropDownMenu_Initialize(dropdown, init, 'MENU')

local function FilterAura(auras, unit, data)
    if data.nameplateShowPersonal then
        return true
    end

    if data.duration < 30 then
        return true
    end

    return false
end

local PostCreateIcon = function(auras, button)
    local countFrame = CreateFrame('Frame', '$parentCountFrame', button)
    countFrame:SetAllPoints(button)

    local c = button.count
    c:ClearAllPoints()
    c:SetPoint('BOTTOMRIGHT', countFrame, 'BOTTOMRIGHT', auras.size*0.35, -(auras.size*0.21))
    -- c:SetPoint('BOTTOMRIGHT', auras.size*0.35, -(auras.size*0.21))
    c:SetFontObject("GameFontNormalOutline")
    local font, _, flags = c:GetFont()
    c:SetFont(font, auras.size*0.6, flags)
    c:SetTextColor(1, 1, 1)

    button.cd:SetReverse(true)
    button.overlay:SetTexture(nil)
    button.icon:SetTexCoord(.05, .95, .2, .7)

    L:ShadowedBorder(button)
end

local PostUpdateIcon = function(_, unit, button)
    local texture = button.icon
    if button.isPlayer or UnitIsFriend('player', unit) or not button.isDebuff then
        texture:SetDesaturated(false)
    else
        texture:SetDesaturated(true)
    end
    button:SetHeight(button:GetWidth()/1.4)
end

local AuraSetPosition = function(element, from, to)
    for i = from, to do
        local button = element[i]
        if i > 1 and ((i % element.buttonsPerRow) == 1) then
            button:SetPoint("BOTTOMLEFT", element[i-element.buttonsPerRow], "TOPLEFT", 0, element.spacing)
        elseif (i > 1) then
            button:SetPoint("LEFT", element[i-1], "RIGHT", element.spacing, 0)
        else
            button:SetPoint("BOTTOMLEFT", element, "BOTTOMLEFT", 0, 0)
        end
    end
end

local function Auras(self)
    local el = C.auras[self.unit:match('[^%d]+')]
    if not el then return end

    local mode = el[1]
    local size = el[2]

    local spacing = 0
    local buttonsPerRow = 0
    local iterations = 0 -- reduce aura per row until loop condition satisfied
    while (spacing < 4) do -- require at least this many pixels spacing between buttons
        local frameWidth = self:GetWidth()
        buttonsPerRow = (math.floor(frameWidth / size) - iterations)
        local leftover = frameWidth - (buttonsPerRow*size)
        spacing = leftover / (buttonsPerRow-1)
        iterations = iterations+1
    end

    local totalButtons = buttonsPerRow

    local b = CreateFrame('Frame', nil, self)
    b.spacing = spacing
    b.num = totalButtons
    b.buttonsPerRow = buttonsPerRow
    b:SetSize(self:GetWidth(), 14)
    b.size = size
    b:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 12)
    b.initialAnchor = 'TOPLEFT'
    b['growth-y'] = 'UP'
    b.PostCreateIcon = PostCreateIcon
    b.PostUpdateIcon = PostUpdateIcon
    b.SetPosition = AuraSetPosition

    if mode == 'aura' then
        b.gap = false
        b.numTotal = totalButtons
        self.Auras = b
    elseif mode == 'debuff' then
        self.Debuffs = b
    else
        self.Buffs = b
    end
end

local PostUpdateHealth = function(health, unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then
        health:SetValue(0)
    end
end

local PostUpdatePower = function(Power, _, _, _, max)
    if (max == 0) then
        Power:Hide()
    else
        Power:Show()
    end
end

local function PostUpdatePowerArenaPreparation(self, specID)
    self:Hide()
end

local function PostUpdateClassPower(element, _, max, hasMaxChanged, powerType)
    if class == "DEATHKNIGHT" then return end
    local ClassPowerPip = element[1]
    local classPowerBar = ClassPowerPip:GetParent()

    if max == nil then
        classPowerBar:Hide()
        return
    end

    classPowerBar:Show()

    local unitFrameParent = element[1]:GetParent():GetParent()
    local anchor
    if unitFrameParent.AdditionalPower and unitFrameParent.AdditionalPower:IsShown() then
        anchor = unitFrameParent.AdditionalPower
    elseif unitFrameParent.Power and unitFrameParent.Power:IsShown() then
        anchor = unitFrameParent.Power
    else
        anchor = unitFrameParent
    end

    classPowerBar:SetPoint("TOP", anchor, "BOTTOM", CLASSPOWER_X_OFFSET, CLASSPOWER_Y_OFFSET)

    if(hasMaxChanged) then
        local multiplier = 0.7

        local newMax = (max > 5) and 5 or max
        local width = (C.sizes.player.width - (C.classIconSpacing * (newMax - 1))) / newMax

        local color = oUF.colors.power[powerType or "COMBO_POINTS"]

        for index = 1, max do
            local pip = element[index]
            pip:SetWidth(width)

            if index <= 5 then
                pip:SetStatusBarColor(color[1], color[2], color[3])
            else
                pip:SetStatusBarColor(color[1] * multiplier, color[2] * multiplier, color[3] * multiplier)
            end
        end

        for index = max+1, 10 do
            local pip = element[index]
            pip:Hide()
        end
    end
end

local PostCastStart = function(self, unit)
    self:PlayReveal()
    self.Spark:Show()
    self:SetStatusBarColor(unpack(self.casting and self.CastingColor or self.ChannelingColor))
    if unit ~= 'player' and self.notInterruptible and UnitCanAttack('player', unit) then
        self:SetStatusBarColor(0.65, 0.65, 0.65)
    end

    local parent = self:GetParent()
    local anchor
    if parent.ClassPowerBar and parent.ClassPowerBar:IsShown() then
        anchor = parent.ClassPowerBar
    elseif parent.AdditionalPower and parent.AdditionalPower:IsShown() then
        anchor = parent.AdditionalPowerHolder
    elseif parent.Power and parent.Power:IsShown() then
        anchor = parent.PowerHolder
    else
        anchor = parent
    end

    self.Icon:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", CASTBAR_X_OFFSET, -CASTBAR_Y_OFFSET)
end

local PostCastStop = function(self)
    if (self.holdTime ~= 0) then return end
    self:SetStatusBarColor(unpack(self.CompleteColor))
    self:PlayAlpha(0, 0.1)
end

local PostCastFailed = function(self, event, unit)
    self:SetStatusBarColor(unpack(self.FailColor))
    self:PlayAlpha(0, 0.1)
end

local CustomTimeText = function(self, duration)
    if self.delay == 0 then
        self.Time:SetFormattedText("%.1f | %.1f", duration, self.max)
    else
        self.Time:SetFormattedText("%.1f | %.1f |cffff0000-%.1f", duration, self.max, self.delay)
    end
end

local Castbar = function(self, unit)
    local iconSpacing = 6
    local cb = createStatusbar(self, C.texture, nil, nil, nil, 1, 1, 1, 1)

    cb.Time = cb:CreateFontString("aLie_CastBarTime", "ARTWORK", "GameFontHighlightOutline")
    cb.Time:SetJustifyH("RIGHT")
    cb.Time:SetPoint('TOPRIGHT', -TEXT_X_OFFSET, TEXT_Y_OFFSET)

    cb.Text = cb:CreateFontString("aLie_CastBarTime", "ARTWORK", "GameFontHighlightOutline")
    cb.Text:SetJustifyH("LEFT")
    cb.Text:SetPoint("TOPLEFT", TEXT_X_OFFSET, TEXT_Y_OFFSET)
    cb.Text:SetPoint('RIGHT', cb.Time, 'LEFT')
    cb.Text:SetText("Example") -- Set so GetFontHeight() returns a value > 0
    cb.Text:SetHeight(cb.Text:GetStringHeight())

    cb.CastingColor = {0, 0.7, 1}
    cb.CompleteColor = {0.12, 0.86, 0.15}
    cb.FailColor = {1.0, 0.09, 0}
    cb.ChannelingColor = {0.32, 0.3, 1}

    cb.Icon = cb:CreateTexture(nil, 'ARTWORK')
    cb.Icon:SetTexCoord(.1, .9, .1, .9)

    cb:SetPoint("BOTTOMLEFT", cb.Icon, "BOTTOMRIGHT", iconSpacing, 0)

    cb.Shield = cb:CreateTexture(nil, 'ARTWORK')
    cb.Shield:SetTexture[[Interface\CastingBar\UI-CastingBar-Arena-Shield]]
    cb.Shield:SetPoint('CENTER', cb.Icon, 'CENTER', 7, 0)

    cb.Spark = cb:CreateTexture(nil,'OVERLAY')
    cb.Spark:SetBlendMode('Add')
    cb.Spark:SetSize(10, cb:GetHeight())
    cb.Spark:SetPoint("CENTER", cb:GetStatusBarTexture(), "RIGHT", 0, 0)

    cb.PostCastStart = PostCastStart
    cb.PostCastStop = PostCastStop
    cb.PostCastFail = PostCastFailed
    cb.PostCastInterruptible = PostCastFailed
    cb.CustomTimeText = CustomTimeText

    cb.timeToHold = 0.75

    L:ShadowedBorder(cb)
    L:ShadowedBorder(cb.Icon)

    L:RegisterAlphaAnimation(cb)

    local cbHeight = self:GetHeight()/CASTBAR_HEIGHT_RATIO
    local textHeight = cb.Text:GetStringHeight();
    local iconSize = (cbHeight+textHeight)-TEXT_Y_OFFSET
    cb.Icon:SetSize(iconSize, iconSize)
    cb.Shield:SetSize(cbHeight*5.25, cbHeight*5.25)
    cb:SetSize(self:GetWidth()-iconSpacing-iconSize, cbHeight)
    self.Castbar = cb
end

local HealthPrediction = function(self)
    local myBar = createStatusbar(self.Health, C.texture, nil, nil, 200, 0.33, 0.59, 0.33, 0.6)
    myBar:SetPoint('TOP')
    myBar:SetPoint('BOTTOM')
    myBar:SetFrameStrata(self.Health:GetFrameStrata())
    myBar:SetFrameLevel(self.Health:GetFrameLevel())
    myBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    myBar:SetWidth(self:GetWidth())
    myBar.Smooth = true

    local otherBar = createStatusbar(self.Health, C.texture, nil, nil, 200, 0.33, 0.59, 0.33, 0.6)
    otherBar:SetPoint('TOP')
    otherBar:SetPoint('BOTTOM')
    otherBar:SetFrameStrata(self.Health:GetFrameStrata())
    otherBar:SetFrameLevel(self.Health:GetFrameLevel())
    otherBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    otherBar:SetWidth(self:GetWidth())
    otherBar.Smooth = true

    local absorbBar = createStatusbar(self.Health, C.texture, nil, nil, 200, 0.33, 0.59, 0.33, 0.6)
    absorbBar:SetPoint('TOP')
    absorbBar:SetPoint('BOTTOM')
    absorbBar:SetFrameStrata(self.Health:GetFrameStrata())
    absorbBar:SetFrameLevel(self.Health:GetFrameLevel())
    absorbBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    absorbBar:SetWidth(self:GetWidth())
    otherBar.Smooth = true

    local healAbsorbBar = createStatusbar(self.Health, C.texture, nil, nil, 200, 0.33, 0.59, 0.33, 0.6)
    healAbsorbBar:SetPoint('TOP')
    healAbsorbBar:SetPoint('BOTTOM')
    healAbsorbBar:SetFrameStrata(self.Health:GetFrameStrata())
    healAbsorbBar:SetFrameLevel(self.Health:GetFrameLevel())
    healAbsorbBar:SetPoint('LEFT', self.Health:GetStatusBarTexture(), 'RIGHT')
    healAbsorbBar:SetWidth(self:GetWidth())
    otherBar.Smooth = true

    self.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        absorbBar = absorbBar,
        healAbsorbBar = healAbsorbBar,
        maxOverflow = 1.1,
        frequentUpdates = true,
    }
end

local Health = function(self)
    local h = createStatusbar(self, C.texture)
    h:SetAllPoints()

    local hbg = h:CreateTexture(nil, 'BACKGROUND')
    hbg:SetDrawLayer('BACKGROUND', 1)
    hbg:SetAllPoints(h)
    hbg:SetTexture(C.texture)

    h.colorTapping = true
    h.colorClass = true
    h.colorReaction = true
    hbg.multiplier = .4

    h.frequentUpdates = false

    h.Smooth = true

    h.PostUpdate = PostUpdateHealth

    h.bg = hbg
    self.Health = h
end

local LFD = function(self)
    local GroupRoleIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
    GroupRoleIndicator:SetSize(16, 16)
    GroupRoleIndicator:SetPoint('RIGHT', -5, 0)

    L:RegisterAlphaAnimation(GroupRoleIndicator)
    GroupRoleIndicator:PlayHide()

    self.GroupRoleIndicator = GroupRoleIndicator
end

local ReadyCheck = function(self)
    local rc = self.Health:CreateTexture(nil, 'OVERLAY')
    rc:SetPoint('CENTER', self.Health, 'LEFT', 0, 0)
    rc:SetSize(12, 12)
    self.ReadyCheck = rc
end

local Power = function(self)
    local powerHolder = CreateFrame("Frame", nil, self)
    powerHolder:SetPoint("LEFT")
    powerHolder:SetPoint("RIGHT")
    powerHolder:SetPoint("TOP", self, "BOTTOM", POWER_X_OFFSET, POWER_Y_OFFSET)
    powerHolder:SetHeight(C.sizes[self.unit:match('[^%d]+')].power)

    local p = createStatusbar(powerHolder, C.texture, nil, nil, nil, 1, 1, 1, 1)
    p:SetPoint('LEFT', (self:GetWidth()/18), 0)
    p:SetPoint('RIGHT', -(self:GetWidth()/18), 0)
    p:SetPoint("TOP")
    p:SetPoint("BOTTOM")

    if self.unit == 'player' then p.frequentUpdates = true end

    p.Smooth = true

    local pbg = p:CreateTexture(nil, 'BACKGROUND')
    pbg:SetAllPoints(p)
    pbg:SetTexture(C.texture)

    p.colorPower = true
    pbg.multiplier = .4
    L:ShadowedBorder(p)
    p:SetFrameStrata(self.Health:GetFrameStrata())
    p:SetFrameLevel(self.Health:GetFrameLevel()+2)
    p.shadowedBackdrop:SetFrameStrata(self.Health:GetFrameStrata())
    p.shadowedBackdrop:SetFrameLevel(self.Health:GetFrameLevel()+1)
    p.shadowedShadow:SetFrameStrata(self.Health:GetFrameStrata())
    p.shadowedShadow:SetFrameLevel(self.Health:GetFrameLevel()+1)

    p.PostUpdate = PostUpdatePower

    p.bg = pbg
    self.Power = p
    self.PowerHolder = powerHolder
end

local AdditionalPower = function(self)
    local powerHolder = CreateFrame("Frame", nil, self)
    powerHolder:SetPoint("LEFT")
    powerHolder:SetPoint("RIGHT")
    powerHolder:SetPoint("TOP", self.PowerHolder, "BOTTOM", 0, -4)
    powerHolder:SetHeight(C.sizes[self.unit:match('[^%d]+')].power)


    local p = createStatusbar(powerHolder, C.texture, nil, nil, nil, 1, 1, 1, 1)
    p:SetPoint('LEFT', (self:GetWidth()/18), 0)
    p:SetPoint('RIGHT', -(self:GetWidth()/18), 0)
    p:SetPoint("TOP")
    p:SetPoint("BOTTOM")

    p.Smooth = true

    local pbg = p:CreateTexture(nil, 'BACKGROUND')
    pbg:SetAllPoints(p)
    pbg:SetTexture(C.texture)

    p.colorPower = true
    pbg.multiplier = .4
    L:ShadowedBorder(p)
    p:SetFrameStrata(self.Health:GetFrameStrata())
    p:SetFrameLevel(self.Health:GetFrameLevel()+1)
    p.shadowedBackdrop:SetFrameStrata(self.Health:GetFrameStrata())
    p.shadowedBackdrop:SetFrameLevel(self.Health:GetFrameLevel()+1)
    p.shadowedShadow:SetFrameStrata(self.Health:GetFrameStrata())
    p.shadowedShadow:SetFrameLevel(self.Health:GetFrameLevel()+1)

    p.bg = pbg
    self.AdditionalPower = p
    self.AdditionalPowerHolder = powerHolder
end

local PhaseIndicator = function(self)
    local PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
    PhaseIndicator:SetPoint("LEFT", -20, 0)
    PhaseIndicator:SetSize(16, 16)
    self.PhaseIndicator = PhaseIndicator
end

local Shared = function(self, ...)
    local unit = self.unit:match('^(.-)%d+') or self.unit
    -- self.unit = unit
    self.menu = menu

    self:SetScript('OnEnter', OnEnter)
    self:SetScript('OnLeave', OnLeave)

    self:RegisterForClicks'AnyUp'

    local width = C.sizes[unit].width
    local height = C.sizes[unit].height
    self:SetSize(width, height)

    Health(self)

    L:ShadowedBorder(self)

    local ricon = self.Health:CreateTexture(nil, 'OVERLAY')
    local riconsize = self.Health:GetHeight()-2
    ricon:SetSize(riconsize, riconsize)
    ricon:SetPoint('RIGHT', -5, 0)
    self.RaidTargetIndicator = ricon

    local hl = self.Health:CreateTexture(nil, nil, nil, 1)
    hl:SetAllPoints(self)
    hl:SetTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
    hl:SetVertexColor(1, 1, 1, 0.15)
    hl:SetBlendMode('ADD')
    hl:Hide()
    self.Highlight = hl
end


local UnitSpecific = {
    player = function(self, ...)
        Shared(self)
        Power(self)
        AdditionalPower(self)
        HealthPrediction(self)

        Auras(self)
        self.Buffs.FilterAura = FilterAura

        local fcf = CreateFrame("Frame", nil, self.Health)
        fcf:SetSize(32, 32)
        fcf:SetPoint("CENTER")
        fcf.mode = "Fountain"
        fcf.fontHeight=16
        for i = 1, 6 do
            fcf[i] = fcf:CreateFontString(nil, "OVERLAY", "CombatTextFont")
        end
        self.FloatingCombatFeedback = fcf

        PetCastingBarFrame:UnregisterAllEvents()
        PetCastingBarFrame.Show = function() end
        PetCastingBarFrame:Hide()

        local htext = self.Health:CreateFontString("aLie_PlayerHealth", "ARTWORK", "GameFontNormalOutline")
        htext:SetJustifyH("RIGHT")
        htext:SetPoint('TOPRIGHT', -TEXT_X_OFFSET, TEXT_Y_OFFSET)
        htext.frequentUpdates = .1
        self:Tag(htext, '[aLie:health]')

        local ptext = self.Health:CreateFontString("aLie_TargetName", "ARTWORK", "GameFontNormalOutline")
        ptext:SetJustifyH("LEFT")
        ptext:SetPoint('TOPLEFT', TEXT_X_OFFSET, TEXT_Y_OFFSET)
        ptext.frequentUpdates = .1
        self:Tag(ptext, '[aLie:power]')

        local ClassPowerBar = CreateFrame('Frame', "ClassPowerBar", self)
        ClassPowerBar:SetWidth(self:GetWidth())
        ClassPowerBar:SetHeight(self.PowerHolder:GetHeight())
        ClassPowerBar:SetPoint("TOP", self.PowerHolder, "BOTTOM", CLASSPOWER_X_OFFSET, CLASSPOWER_Y_OFFSET)
        self.ClassPowerBar = ClassPowerBar

        local ClassPower = {}
        ClassPower.PostUpdate = PostUpdateClassPower

        for index = 1, 11 do
            local ClassPowerPip = CreateFrame("StatusBar", "ClassPowerPip"..index, ClassPowerBar)
            ClassPowerPip:SetStatusBarTexture(C.texture)
            ClassPowerPip:SetHeight(ClassPowerBar:GetHeight())
            ClassPowerPip:SetWidth(16)
            L:ShadowedBorder(ClassPowerPip)

            if index > 5 then
                ClassPowerPip:SetPoint("LEFT", ClassPower[index-5], "LEFT", 0, 0)
                ClassPowerPip:SetFrameLevel(ClassPower[1]:GetFrameLevel()+1)
            elseif index > 1 then
                ClassPowerPip:SetPoint('LEFT', ClassPower[index-1], 'RIGHT', C.classIconSpacing, 0)
            else
                ClassPowerPip:SetPoint('LEFT', ClassPowerBar, 'LEFT', 0, 0)
            end

            ClassPower[index] = ClassPowerPip
        end

        self.ClassPower = ClassPower

        if(class == 'DEATHKNIGHT') then
            local Runes = {}
            local totalRunes = 6
            local width = (C.sizes.player.width - (C.classIconSpacing * (totalRunes - 1))) / totalRunes
            for index = 1, totalRunes do
                local Rune = CreateFrame('StatusBar', "Rune"..index, ClassPowerBar)
                Rune:SetSize(width, ClassPowerBar:GetHeight())
                Rune:SetStatusBarTexture(C.texture)
                L:ShadowedBorder(Rune)

                if index > 1 then
                    Rune:SetPoint('LEFT', Runes[index - 1], 'RIGHT', C.classIconSpacing, 0)
                else
                    Rune:SetPoint('LEFT', ClassPowerBar, 'LEFT', 0, 0)
                end

                Runes[index] = Rune
            end
            Runes.colorSpec = true
            self.Runes = Runes
        end

        Castbar(self)

        self.GCD = CreateFrame('Frame', nil, self.Health)
        self.GCD:SetPoint('LEFT', self.Health, 'LEFT')
        self.GCD:SetPoint('RIGHT', self.Health, 'RIGHT')
        self.GCD:SetHeight(C.sizes[self.unit].height + 4)

        self.GCD.Spark = self.GCD:CreateTexture(nil, "OVERLAY")
        self.GCD.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        self.GCD.Spark:SetBlendMode("ADD")
        self.GCD.Spark:SetHeight((C.sizes[self.unit].height * 2)+4)
        self.GCD.Spark:SetWidth(9)
        self.GCD.Spark:SetPoint('LEFT', self.Health, 'LEFT', 0, 0)

        local altp = createStatusbar(self, C.texture, nil, C.sizes[self.unit].power, self:GetWidth(), 1, 1, 1, 1)
        altp:SetPoint("BOTTOM", self, "TOP", 0, 3)
        altp.bg = altp:CreateTexture(nil, 'BORDER')
        altp.bg:SetAllPoints(altp)
        altp.bg:SetTexture(C.texture)
        altp.bg:SetVertexColor(1, 1, 1, 0.3)
        altp.Text = altp:CreateFontString("aLie_AltPower", "ARTWORK", "GameFontNormalOutline")
        altp.Text:SetJustifyH("LEFT")
        altp.Text:SetPoint("BOTTOM", altp, "TOP", 0, -2)
        self:Tag(altp.Text, '[aLie:altpower]')
        altp:EnableMouse(true)
        L:ShadowedBorder(altp)
        self.AlternativePower = altp

        L:RegisterAlphaAnimation(self)

        if C.hidePlayerFrameOoc then
            self:RegisterEvent("PLAYER_REGEN_ENABLED", LeaveCombat, true)
            self:RegisterEvent("PLAYER_REGEN_DISABLED", EnterCombat, true)
            self:RegisterEvent("UNIT_HEALTH", HealthUpdate)
            self:RegisterEvent("UNIT_SPELLCAST_START", SpellStart)
            self:RegisterEvent("UNIT_SPELLCAST_STOP", SpellFinish)
            self:RegisterEvent("UNIT_ENTERED_VEHICLE", EnterVehicle)
            self:RegisterEvent("UNIT_EXITED_VEHICLE", ExitVehicle)
            self:PlayHide()
        end
    end,

    target = function(self, ...)
        Shared(self)
        Power(self)
        HealthPrediction(self)
        Castbar(self)
        PhaseIndicator(self)
        Auras(self)

        local htext = self.Health:CreateFontString("aLie_TargetHealth", "ARTWORK", "GameFontNormalOutline")
        htext:SetJustifyH("RIGHT")
        htext:SetPoint('TOPRIGHT', self, -TEXT_X_OFFSET, TEXT_Y_OFFSET)
        htext.frequentUpdates = .1
        self:Tag(htext, '[aLie:health]')

        local name = self.Health:CreateFontString("aLie_TargetName", "ARTWORK", "GameFontNormalOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('TOPLEFT', self, TEXT_X_OFFSET, TEXT_Y_OFFSET)
        name:SetPoint('RIGHT', htext, 'LEFT', -3, 0)
        name:SetHeight(10)
        self:Tag(name, '[aLie:level<$ ][aLie:name]')
    end,

    focus = function(self, ...)
        Shared(self)
        Power(self)
        HealthPrediction(self)
        Castbar(self)
        PhaseIndicator(self)
        Auras(self)

        local htext = self.Health:CreateFontString("aLie_FocusHealth", "ARTWORK", "GameFontNormalOutline")
        htext:SetJustifyH("RIGHT")
        htext:SetPoint('TOPRIGHT', self, -TEXT_X_OFFSET, TEXT_Y_OFFSET)
        self:Tag(htext, '[aLie:health]')

        local name = self.Health:CreateFontString("aLie_FocusName", "ARTWORK", "GameFontNormalOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('TOPLEFT', self, TEXT_X_OFFSET, TEXT_Y_OFFSET)
        name:SetHeight(10)
        name:SetPoint('RIGHT', htext, 'LEFT', -3, 0)
        self:Tag(name, '[aLie:level<$ ][aLie:name]')
    end,

    boss = function(self, ...)
        Shared(self)
        Power(self)
        Castbar(self)
        PhaseIndicator(self)
        Auras(self)

        local htext = self.Health:CreateFontString("aLie_BossHealth", "ARTWORK", "GameFontNormalOutline")
        htext:SetJustifyH("RIGHT")
        htext:SetPoint('TOPRIGHT', self, -TEXT_X_OFFSET, TEXT_Y_OFFSET)
        self:Tag(htext, '[aLie:health]')

        local name = self.Health:CreateFontString("aLie_BossName", "ARTWORK", "GameFontNormalOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('TOPLEFT', self, TEXT_X_OFFSET, TEXT_Y_OFFSET)
        name:SetHeight(10)
        name:SetPoint('RIGHT', htext, 'LEFT')
        self:Tag(name, '[aLie:name]')

        local altp = createStatusbar(self, C.texture, nil, self.Power:GetHeight(), self:GetWidth(), 1, 1, 1, 1)
        altp:SetPoint('BOTTOM', self, 'TOP', 0, 5)
        altp.bg = altp:CreateTexture(nil, 'BORDER')
        altp.bg:SetAllPoints(altp)
        altp.bg:SetTexture(C.texture)
        altp.bg:SetVertexColor(1, 1, 1, 0.3)
        altp.Text = altp:CreateFontString("aLie_AltPower", "ARTWORK", "GameFontNormalOutline")
        altp.Text:SetJustifyH("LEFT")
        altp.Text:SetPoint('CENTER')
        altp:EnableMouse(true)
        altp.colorTexture = true
        self:Tag(altp.Text, '[aLie:altpower]')
        L:ShadowedBorder(altp)
        self.AlternativePower = altp
    end,

    pet = function(self, ...)
        Shared(self)
        HealthPrediction(self)
        PhaseIndicator(self)

        local name = self.Health:CreateFontString("aLie_PetName", "ARTWORK", "GameFontNormalOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('CENTER', self.Health, 0, 3)
        self:Tag(name, '[aLie:name]')
        self.Name = name;
        self.Name:Hide();

        self:SetScript('OnEnter', function(self)UIFrameFadeIn(self.Name, 0.3, 0, 1)end)
        self:SetScript('OnLeave', function(self)UIFrameFadeOut(self.Name, 0.3, 1, 0)end)

        if C.hidePlayerFrameOoc then
            L:RegisterAlphaAnimation(self)
            self:PlayHide()
        end
    end,

    targettarget = function(self, ...)
        Shared(self)
        Auras(self)

        local name = self.Health:CreateFontString("aLie_TargetTargetName", "ARTWORK", "GameFontNormalOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('CENTER', 0, TEXT_Y_OFFSET)
        self:Tag(name, '[aLie:shortname]')
    end,

    party = function(self, ...)
        Shared(self)
        Power(self)
        HealthPrediction(self)
        PhaseIndicator(self)
        LFD(self)
        ReadyCheck(self)
        Auras(self)

        local htext = self.Health:CreateFontString("aLie_PartyHealth", "ARTWORK", "GameFontNormalOutline")
        htext:SetJustifyH("RIGHT")
        htext:SetPoint('TOPRIGHT', self, -TEXT_X_OFFSET, TEXT_Y_OFFSET)
        self:Tag(htext, '[aLie:health]')

        local name = self.Health:CreateFontString("aLie_PartyName", "ARTWORK", "GameFontNormalOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('TOPLEFT', self, TEXT_X_OFFSET, TEXT_Y_OFFSET)
        name:SetHeight(10)
        name:SetPoint('RIGHT', htext, 'LEFT', -3, 0)
        self:Tag(name, '[aLie:level<$ ][aLie:name]')
    end,

    tank = function(self, ...)
        Shared(self)
        Power(self)
        HealthPrediction(self)
        PhaseIndicator(self)
        LFD(self)
        Auras(self)

        local htext = self.Health:CreateFontString("aLie_TankHealth", "ARTWORK", "GameFontNormalOutline")
        htext:SetJustifyH("RIGHT")
        htext:SetPoint('TOPRIGHT', self, -TEXT_X_OFFSET, TEXT_Y_OFFSET)
        self:Tag(htext, '[aLie:health]')

        local name = self.Health:CreateFontString("aLie_TankName", "ARTWORK", "GameFontNormalOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('TOPLEFT', self, TEXT_X_OFFSET, TEXT_Y_OFFSET)
        name:SetHeight(10)
        name:SetPoint('RIGHT', htext, 'LEFT', -3, 0)
        self:Tag(name, '[aLie:level<$ ][aLie:name]')

        local rc = self.Health:CreateTexture(nil, 'OVERLAY')
        rc:SetPoint('CENTER')
        rc:SetSize(12, 12)
        self.ReadyCheck = rc
    end,

    arena = function(self, ...)
        Shared(self)
        Power(self)
        Castbar(self)
        Auras(self)

        local htext = self.Health:CreateFontString("aLie_ArenaHealth", "ARTWORK", "GameFontNormalOutline")
        htext:SetJustifyH("RIGHT")
        htext:SetPoint('TOPRIGHT', self, -TEXT_X_OFFSET, TEXT_Y_OFFSET)
        self:Tag(htext, '[aLie:health]')

        local name = self.Health:CreateFontString("aLie_ArenaName", "ARTWORK", "GameFontHighlightOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('TOPLEFT', self, TEXT_X_OFFSET, TEXT_Y_OFFSET)
        name:SetHeight(10)
        name:SetPoint('RIGHT', htext, 'LEFT', -3, 0)
        self:Tag(name, '[arenaspec]')

        local t = CreateFrame('Frame', nil, self)
        t:SetSize(C.sizes[self.unit:match('[^%d]+')].height, C.sizes[self.unit:match('[^%d]+')].height)
        t:SetPoint('TOPRIGHT', self, 'TOPLEFT', -4, 0)
        L:ShadowedBorder(t)
        self.Trinket = t

        self.Power.PostUpdateArenaPreparation = PostUpdatePowerArenaPreparation
    end,

    raid = function(self, ...)
        Shared(self)
        HealthPrediction(self)
        LFD(self)
        ReadyCheck(self)

        local name = self.Health:CreateFontString("aLie_RaidName", "ARTWORK", "GameFontNormalOutline")
        name:SetJustifyH("LEFT")
        name:SetPoint('TOPLEFT', self, TEXT_X_OFFSET, TEXT_Y_OFFSET)
        self:Tag(name, '[aLie:shortname]')
    end,
}

UnitSpecific.focustarget = UnitSpecific.targettarget

local hider = CreateFrame("Frame", "Hider", UIParent)
hider:Hide()

oUF:RegisterStyle('aLie', Shared)
for unit,layout in next, UnitSpecific do
    oUF:RegisterStyle('aLie - ' .. unit:gsub('^%l', string.upper), layout)
end

local function spawnHelper(self, unit, pos)
    local baseUnit = unit:match('^(.-)%d+') or unit
    if not C.sizes[baseUnit] then return end

    if(UnitSpecific[unit]) then
        self:SetActiveStyle('aLie - ' .. unit:gsub('^%l', string.upper))
    elseif(UnitSpecific[unit:match('[^%d]+')]) then
        self:SetActiveStyle('aLie - ' .. unit:match('[^%d]+'):gsub('^%l', string.upper))
    else
        self:SetActiveStyle('aLie')
    end
    local object = self:Spawn(unit)
    object:SetPoint(unpack(pos))
    return object
end

local function partySpawn(self)
    if not C.enabled.party then return end

    for i = 1, MAX_PARTY_MEMBERS do
        local pet = 'PartyMemberFrame'..i..'PetFrame'
        if _G[pet] then
            _G[pet]:SetParent(hider)
            _G[pet..'HealthBar']:UnregisterAllEvents()
        end
    end

    local adjuster = C.auras.party and C.auras.party[2] or 0
    local yOffset =  -23 + -adjuster

    self:SetActiveStyle('aLie - Party')
    local party = self:SpawnHeader(nil, nil, 'custom [@arena1,exists][@arena2,exists][@arena3,exists][group:party,nogroup:raid] show; hide',
                                   'showPlayer', false,
                                   'showSolo', false,
                                   'showParty', true,
                                   'yOffset', yOffset,
                                   'oUF-initialConfigFunction',
                                   ([[
            self:SetHeight(%d)
            self:SetWidth(%d)
        ]]):format(C.sizes.party.height, C.sizes.party.width)
    )

    party:SetPoint(unpack(C.positions.party))
end

local function maintankSpawn(self)
    if not C.enabled.maintank then return end

    local adjuster = C.auras.maintank and C.auras.maintank[2] or 0
    local yOffset =  -23 + -adjuster

    self:SetActiveStyle('aLie - Tank')
    local maintank = self:SpawnHeader('oUF_MainTank', nil, 'raid',
                                      'showRaid', true,
                                      'showSolo', false,
                                      'groupFilter', 'MAINTANK',
                                      'yOffset', yOffset,
                                      'oUF-initialConfigFunction',
                                      ([[
            self:SetHeight(%d)
            self:SetWidth(%d)
        ]]):format(C.sizes.maintank.height, C.sizes.maintank.width)
    )

    maintank:SetPoint(unpack(C.positions.maintank))
end

local function raidSpawn(self)
    if not C.enabled.raid then return end

    if IsAddOnLoaded('Blizzard_CompactRaidFrames') then
        CompactRaidFrameManager:SetParent(hider)
        CompactUnitFrameProfiles:UnregisterAllEvents()
    end

    self:SetActiveStyle('aLie - Raid')
    local raid = oUF:SpawnHeader(nil, nil, 'raid',
                                 'showPlayer', true,
                                 'showSolo', false,
                                 'showParty', false,
                                 'showRaid', true,
                                 'xoffset', 8,
                                 'yOffset', -8,
                                 'point', 'TOP',
                                 'groupFilter', '1,2,3,4,5,6,7,8',
                                 'groupingOrder', '1,2,3,4,5,6,7,8',
                                 'groupBy', 'GROUP',
                                 'maxColumns', 8,
                                 'unitsPerColumn', 5,
                                 'columnSpacing', 8,
                                 'columnAnchorPoint', 'LEFT',
                                 'oUF-initialConfigFunction', ([[
        self:SetHeight(%d)
        self:SetWidth(%d)
    ]]):format(C.sizes.raid.height, C.sizes.raid.width)
    )

    raid:SetPoint(unpack(C.positions.raid))
end

local function bossSpawn(self)
    if not C.enabled.boss then return end

    spawnHelper(self, "boss1", C.positions.boss)

    local adjuster = C.auras.boss and C.auras.boss[2] or 0
    local bossCastBar = _G['oUF_aLieBoss1'].Castbar
    local bossPowerBar = _G['oUF_aLieBoss1'].Power
    local bossyOffset = bossCastBar:GetHeight() + (CASTBAR_Y_OFFSET*3) + bossPowerBar:GetHeight() + adjuster

    for i = 2, MAX_BOSS_FRAMES do
        local pos = { 'BOTTOMLEFT', 'oUF_aLieBoss'..i-1, 'TOPLEFT', 0, bossyOffset }
        spawnHelper(self, 'boss' .. i, pos)
    end
end

local function arenaSpawn(self)
    if not C.enabled.arena then return end

    spawnHelper(self, "arena1", C.positions.arena)

    -- FIXME: arena doesn't spawn?
    if not _G['oUF_aLieArena1'] then return end

    local adjuster = C.auras.arena and C.auras.arena[2] or 0
    local arenaCastBar = _G['oUF_aLieArena1'].Castbar
    local arenaPowerBar = _G['oUF_aLieArena1'].Power
    local arenayOffset = arenaCastBar:GetHeight() + (CASTBAR_Y_OFFSET*3) + arenaPowerBar:GetHeight() + adjuster

    for i = 2, 5 do
        local pos = { "BOTTOM", "oUF_aLieArena"..i-1, "TOP", 0, arenayOffset }
        spawnHelper(self, "arena" ..i, pos)
    end
end

local function playerSpawn(self)
    if not C.enabled.player then return end

    spawnHelper(self, 'player', C.positions.player)

    if not C.emulatePersonalResourceDisplay then return end

    SetCVar("nameplateShowSelf", 1)
    SetCVar("NameplatePersonalShowAlways", 1)
    SetCVar("NameplatePersonalShowWithTarget", 2) -- Show with friendly and hostile targets
    SetCVar("nameplateSelfAlpha", 0)
    C_NamePlate.SetNamePlateSelfClickThrough(true)

    local f = CreateFrame("frame")
    f:RegisterEvent("NAME_PLATE_UNIT_ADDED", "player")
    f:RegisterEvent("NAME_PLATE_UNIT_REMOVED", "player")

    f:SetScript("OnEvent", function(self, event, unit)
                    -- do nothing if the nameplate is not ours
                    if not UnitIsUnit(unit, "player") then return end

                    local namePlate = C_NamePlate.GetNamePlateForUnit(unit, issecure());
                    -- return if we're locked
                    if not namePlate or InCombatLockdown() then return end

                    oUF_aLiePlayer:ClearAllPoints()
                    if event == "NAME_PLATE_UNIT_ADDED" then
                        oUF_aLiePlayer:SetPoint("CENTER", namePlate, "CENTER", 0, -30)
                    else
                        oUF_aLiePlayer:SetPoint(unpack(C.positions.player))
                    end
    end)
end

oUF:Factory(function(self)
        playerSpawn(self)
        spawnHelper(self, "target", C.positions.target)
        spawnHelper(self, "targettarget", C.positions.targettarget)
        spawnHelper(self, "focus", C.positions.focus)
        spawnHelper(self, "focustarget", C.positions.focustarget)
        spawnHelper(self, "pet", C.positions.pet)

        partySpawn(self)
        raidSpawn(self)
        maintankSpawn(self)
        bossSpawn(self)
        arenaSpawn(self)
end)
