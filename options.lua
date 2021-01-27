local A, aLie = ...

local LibAddonUtils = LibStub("LibAddonUtils-1.0")
local GUI = LibStub("LibAddonGUI-1.0"):RegisterAddon(A)

aLie.defaultOptions = {
    AltBuy = true,
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
    FlightPaths = false,
    InputLagFix = true,
    Screensaver = true,
}

local function setDefault(n, val)
    if aLieDB == nil then
        aLieDB = aLie:CopyTable(aLie.defaultOptions)
        return
    end

    if aLieDB[n] == nil then
        aLieDB[n] = val
    end
end

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
    for n,v in pairs(aLie.defaultOptions) do
        setDefault(n,v)
    end
    
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

function registerControl(control, parentFrame)
    if ( ( not parentFrame ) or ( not control ) ) then
        return;
    end

    parentFrame.controls = parentFrame.controls or {};

    tinsert(parentFrame.controls, control);
end

local function lockInCombat(frame)
    frame:SetScript("OnUpdate", function(self)
        if not InCombatLockdown() then
            self:Enable()
        else
            self:Disable()
        end
    end)
end

local prevControl
local function createLabel(cfg)
    --[[
        {
            type = "Label",
            name = "LabelName",
            parent = Options,
            label = L.LabelText,
            fontObject = "GameFontNormalLarge",
            relativeTo = LeftSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -16,
        },
    --]]
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -16
    cfg.relativeTo = cfg.relativeTo or prevControl
    cfg.fontObject = cfg.fontObject or "GameFontNormalLarge"

    local label = cfg.parent:CreateFontString(cfg.name, "ARTWORK", cfg.fontObject)
    label:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    label:SetText(cfg.label)

    prevControl = label
    return label
end

local function createCheckBox(cfg)
    --[[
        {
            type = "CheckBox",
            name = "Test",
            parent = parent,
            label = L.TestLabel,
            tooltip = L.TestTooltip,
            isCvar = nil or True,
            var = "TestVar",
            reload = nil or True,
            disableInCombat = nil or True,
            func = function(self)
                -- Do stuff here.
            end,
            initialPoint = "TOPLEFT",
            relativeTo = frame,
            relativePoint, "BOTTOMLEFT",
            offsetX = 0,
            offsetY = -6,
        },
    --]]
    cfg.initialPoint = cfg.initialPoint or "TOPLEFT"
    cfg.relativePoint = cfg.relativePoint or "BOTTOMLEFT"
    cfg.offsetX = cfg.offsetX or 0
    cfg.offsetY = cfg.offsetY or -6
    cfg.relativeTo = cfg.relativeTo or prevControl

    local checkBox = CreateFrame("CheckButton", cfg.name, cfg.parent, "InterfaceOptionsCheckButtonTemplate")
    checkBox:SetPoint(cfg.initialPoint, cfg.relativeTo, cfg.relativePoint, cfg.offsetX, cfg.offsetY)
    checkBox.Text:SetText(cfg.label)
    checkBox.GetValue = function(self) return checkBox:GetChecked() end
    checkBox.SetValue = function(self) checkBox:SetChecked(aLieDB[cfg.var]) end
    checkBox.var = cfg.var
    checkBox.isCvar = cfg.isCvar

    if cfg.tooltip then
        if cfg.reload then
            cfg.tooltip = cfg.tooltip.." "..RED_FONT_COLOR:WrapTextInColorCode(REQUIRES_RELOAD)
        end
        checkBox.tooltipText = cfg.tooltip
    end

    if cfg.disableInCombat then
        lockInCombat(checkBox)
    end

    checkBox:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        checkBox.value = checked
        if cfg.reload then
            needsReload = true
        end
        if cfg.func then
            cfg.func(self)
        end
    end)

    registerControl(checkBox, cfg.parent)
    prevControl = checkBox
    return checkBox
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

    local UIControls = {
        {
            type = "Label",
            name = "OptionsLabel",
            parent = Options,
            label = "aLie Options",
            relativeTo = LeftSide,
            relativePoint = "TOPLEFT",
            offsetX = 16,
            offsetY = -16,
        },
        {
            type = "CheckBox",
            name = "AltBuy",
            parent = Options,
            label = "Buy with Alt",
            tooltip = "Buy a full stack using Alt+Click",
            var = "AltBuy",
            relativeTo = OptionsLabel,
            offsetY = -12,
        },
        {
            type = "CheckBox",
            name = "SellPoors",
            parent = Options,
            label = "Sell gray",
            tooltip = "Sell gray items while visiting a merchant",
            var = "SellPoors",
        },
        {
            type = "CheckBox",
            name = "FastLoot",
            parent = Options,
            label = "Fast autoloot",
            tooltip = "Patch autoloot to perform a faster, almost instant, routine. This will greatly speedup autoloot.",
            var = "FastLoot",
        },
        {
            type = "CheckBox",
            name = "VignetteAlerts",
            parent = Options,
            label = "Vignette alerts",
            tooltip = "Alerts when you detect a rare npc, chest or item",
            var = "VignetteAlerts",
        },
        {
            type = "CheckBox",
            name = "Repair",
            parent = Options,
            label = "Automatically repair",
            tooltip = "Automatically repair gear when visiting an able smith.",
            var = "Repair",
            reload = true,
        },
        {
            type = "CheckBox",
            name = "FlightPaths",
            parent = Options,
            label = "Show flight paths",
            tooltip = "Show all flight paths even if locked.",
            var = "FlightPaths",
            reload = true,
        },
        {
            type = "CheckBox",
            name = "MapPinsTrack",
            parent = Options,
            label = "Track MapPins",
            tooltip = "Automatically track map pins upon creation",
            var = "MapPinsTrack",
        },
        {
            type = "CheckBox",
            name = "MapPinsAlpha",
            parent = Options,
            label = "Always show MapPins",
            tooltip = "Always show MapPins with full opacity, does not work between continents",
            var = "MapPinsAlpha",
            reload = true,
        },
        {
            type = "CheckBox",
            name = "MapPinsTomTom",
            parent = Options,
            label = "Fake TomTom",
            tooltip = "Fakes the TomTom addon api. Most addons will place a MapPin. Disabled if TomTom is installed.",
            var = "MapCoords",
        },
        {
            type = "CheckBox",
            name = "ObjectiveTracker",
            parent = Options,
            label = "Modify Objective Tracker",
            tooltip = "Modify Objective Tracker position and alpha",
            var = "ObjectiveTracker",
            reload = true,
        },
        {
            type = "CheckBox",
            name = "GuildbankRepair",
            parent = Options,
            label = "Guild Repair",
            tooltip = "Use guild's funds to automatically repair your gear",
            var = "GuildbankRepair",
        },
        {
            type = "CheckBox",
            name = "CombatText",
            parent = Options,
            label = "Combat Text style",
            tooltip = "Set better font flags for combat text. Does not changes it's font.",
            var = "CombatText",
            reload = true,
        },
        {
            type = "CheckBox",
            name = "InputLagFix",
            parent = Options,
            label = "Input Lag fix",
            tooltip = "Modify SpellQueueWindow to an automatic value based on haste and current lag",
            var = "InputLagFix",
            reload = true,
        },
        {
            type = "CheckBox",
            name = "Screensaver",
            parent = Options,
            label = "Screensaver",
            tooltip = "Galaxy Screensaver while AFK",
            var = "Screensaver",
            reload = true,
        },
        {
            type = "CheckBox",
            name = "ScreenshotAchi",
            parent = Options,
            label = "Achievement Screenshot",
            tooltip = "Automatically screenshot character Achievements",
            var = "ScreenshotAchi",
            reload = true,
        },
    }

    for _, control in pairs(UIControls) do
        if control.type == "Label" then
            createLabel(control)
        elseif control.type == "CheckBox" or control.type == nil then
            createCheckBox(control)
        end
    end

    function Options:Refresh()
        for _, control in pairs(self.controls) do
            control:SetValue(control)
            control.oldValue = control:GetValue()
        end
    end

    Options:Refresh()
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
