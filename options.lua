local A, aLie = ...

local LibAddonUtils = LibStub("LibAddonUtils-1.0")
local GUI = LibStub("LibAddonGUI-1.0"):RegisterAddon(A)

aLie.defaultOptions = {
    SellPoors = false,
    FastLoot = false,
    VignetteAlerts = false,
    CombatText = false,
    MapPinsTrack = true,
    MapPinsAlpha = true,
    MapPinsTomTom = true,
    ScreenshotAchi = true,
    UIScale = true,
    Repair = true,
    GuildbankRepair = false,
}

local backup = {}
local needsReload = false

local function Truthy(val)
    return val ~= nil
        and val ~= false
        and val ~= 0
        and val ~= ""
end


local Options = CreateFrame("Frame", "aLieOptions", InterfaceOptionsFramePanelContainer)

function Options:Init(evt)
    self.profileBackup = {}
    self.name = GetAddOnMetadata(A, "Title")
    self.version = GetAddOnMetadata(A, "Version")
    self.okay = self.SaveChanges
    self.default = self.RestoreDefaults

    InterfaceOptions_AddCategory(self)
end

function Options:SaveProfileBackup()
    backup = aLie:CopyTable(aLieDB)
end

function Options:SaveChanges()
    if needsReload then
        ReloadUI()
    end
end

function Options:OnShow()
    local panelWidth = Options:GetWidth()/2

    local LeftSide = CreateFrame("Frame", "LeftSide", Options)
    LeftSide:SetHeight(Options:GetHeight())
    LeftSide:SetWidth(panelWidth)
    LeftSide:SetPoint("TOPLEFT", Options)

    local RightSide = CreateFrame("Frame", "RightSide", Options)
    RightSide:SetHeight(Options:GetHeight())
    RightSide:SetWidth(panelWidth)
    RightSide:SetPoint("TOPRIGHT", Options)

    --- local optionsFrame = GUI:CreateFrame(Options, { name = "MainOptions", title = "aLie Options", draggable = false, })

    local function genCheckbutton(parent, var, label, tooltip)
        local c, _ = GUI:CreateCheckButton(
            parent, {
                name = var,
                label = label,
                onShow = function(self) self:SetChecked(Truthy(aLieDB[var])) end,
                onClick = function(self) aLieDB[var] = self:GetChecked() end,
                tooltip = tooltip,
        })

        c:SetChecked(Truthy(aLieDB[var]))
        return c
    end

    local SellPoors, _ = genCheckbutton(
        LeftSide,
        'SellPoors',
        'Sell grays',
        'Automatically sell gray items when visiting a vendor')
    SellPoors:SetPoint("TOPLEFT", LeftSide, "TOPLEFT", 5, -10)

    local FastLoot = genCheckbutton(
        LeftSide,
        'FastLoot',
        'Fast autoloot',
        'Patch autoloot to perform a faster routine. Beware this will greatly speedup autoloot!')
    FastLoot:SetPoint("TOPLEFT", SellPoors, "BOTTOMLEFT", 0, -10)

    local VignetteAlerts, _ = genCheckbutton(
        LeftSide,
        'VignetteAlerts',
        'Vignette alerts',
        'Alerts when you detect a rare npc, chest or item')
    VignetteAlerts:SetPoint("TOPLEFT", FastLoot, "BOTTOMLEFT", 0, -10)

    local Repair = genCheckbutton(
        LeftSide,
        'Repair',
        'Automatically repair',
        'Automatically repair gear when visiting an able smith.')
    Repair:SetPoint("TOPLEFT", VignetteAlert, "BOTTOMLEFT", 0, -10)

    local RepairGB = genCheckbutton(
        LeftSide,
        'GuildbankRepair',
        'Guild Repair',
        'Use Guild Funds to repair')
    RepairGB:SetPoint("TOPLEFT", Repair, "BOTTOMLEFT", 0, -10)


    -- Right side

    local MapPinsTrack = genCheckbutton(
        RightSide,
        'MapPinsTrack',
        'Automatically track map pins')
    MapPinsTrack:SetPoint("TOPLEFT", RightSide, "TOPLEFT", 5, -10)

    local MapPinsAlpha = genCheckbutton(
        RightSide,
        'MapPinsAlpha',
        'Always show map pins')
    MapPinsAlpha:SetPoint("TOPLEFT", MapPinsTrack, "BOTTOMLEFT", 0, -10)

    local MapPinsTomTom = genCheckbutton(
        RightSide,
        'MapPinsTomTom',
        'Map pins TomTom compat',
        'Compatibility layer between Blizzard\'s map pins and TomTom')
    MapPinsTomTom:SetPoint("TOPLEFT", MapPinsAlpha, "BOTTOMLEFT", 0, -10)

    Options:SetScript("OnShow", nil)
end
Options:SetScript("OnShow", Options.OnShow)
Options:Hide()

Options:SetScript("OnEvent", function(self, event, ...)
    if Options[event] ~= nil then
        Options[event](self, ...); -- call one of the functions above
    end
end)

function Options:VARIABLES_LOADED(event, ...)
    self:Init()
    self:SaveProfileBackup()
    self:UnregisterEvent("VARIABLES_LOADED")
end

for _,evt in ipairs({"ADDON_LOADED", "VARIABLES_LOADED"}) do
    Options:RegisterEvent(evt)
end

aLie.options = Options
