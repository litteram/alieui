local A, aLib = ...

local mediapath = "Interface\\AddOns\\".. A .."\\media\\"

-- Position
-- Minimap:ClearAllPoints()
Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
Minimap:SetSize(180,180)

-- Square Shape
Minimap:SetMaskTexture('Interface\\ChatFrame\\ChatFrameBackground')

-- Border
MinimapBorder:Hide()
MinimapBorderTop:Hide()

-- Zoom
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, direction)
                      if direction > 0 then
                          _G.MinimapZoomIn:Click()
                      elseif direction < 0 then
                          _G.MinimapZoomOut:Click()
                      end
end)
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()

-- Voice
-- MiniMapVoiceChatFrame:Hide()

-- Compass
MinimapNorthTag:SetTexture(nil)

-- Zone
MinimapZoneText:SetFontObject("GameFontNormalOutline")
MinimapZoneText:SetPoint("LEFT", Minimap, "LEFT", 0, 0)
MinimapZoneText:SetPoint("RIGHT", Minimap, "RIGHT", 0, 0)
MinimapZoneText:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -15)
MinimapZoneText:SetParent(Minimap)

-- Clock
-- Blizzard_TimeManager
LoadAddOn("Blizzard_TimeManager")
TimeManagerClockButton:GetRegions():Hide()
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("BOTTOM",0,5)
TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")
TimeManagerClockTicker:SetTextColor(0.8,0.8,0.6,1)

-- GameTimeFrame
GameTimeFrame:SetParent(Minimap)
GameTimeFrame:SetScale(0.6)
GameTimeFrame:ClearAllPoints()
GameTimeFrame:SetPoint("TOP",Minimap,0,0)
GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
GameTimeFrame:GetNormalTexture():SetTexCoord(0,1,0,1)
GameTimeFrame:SetNormalTexture(mediapath.."calendar.blp")
GameTimeFrame:SetPushedTexture(nil)
GameTimeFrame:SetHighlightTexture (nil)
local fs = GameTimeFrame:GetFontString()
fs:ClearAllPoints()
fs:SetPoint("CENTER",0,-5)
fs:SetFont(STANDARD_TEXT_FONT,20)
fs:SetTextColor(0.2,0.2,0.1,0.9)

-- Garrison
do
    -- GarrisonLandingPageMinimapButton:Hide()
    -- GarrisonLandingPageMinimapButton:UnregisterAllEvents();
    hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
                       self:SetScale(.55)
                       self:ClearAllPoints()
                       self:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, 0)
    end)
end


-- Tracking
MiniMapTrackingBackground:SetAlpha(0)
MiniMapTrackingButton:SetAlpha(0)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("TOPRIGHT", Minimap, 0, 0)
MiniMapTracking:SetScale(.9)

-- Mail
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOPLEFT", Minimap, 0, 0)
MiniMapMailFrame:SetFrameStrata("LOW")
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture("Interface\\Minimap\\ObjectIcons.blp")
MiniMapMailIcon:SetTexCoord(0.875, 1, 0.25, 0.375)

-- Queues
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", 0, 0)
QueueStatusMinimapButtonBorder:Hide()

-- Instance
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:Hide()

-- World Map
MiniMapWorldMapButton:Hide()

-- Durability Frame
DurabilityFrame:ClearAllPoints()
DurabilityFrame:SetParent(MinimapCluster)
DurabilityFrame:SetPoint("TOP",MinimapCluster,"BOTTOM",0,0)


-- onEnter
local function Show()
    GameTimeFrame:SetAlpha(0.9)
    TimeManagerClockButton:SetAlpha(0.9)
    MiniMapTracking:SetAlpha(0.9)
    MiniMapChallengeMode:SetAlpha(0.9)
    MiniMapInstanceDifficulty:SetAlpha(0.9)
    GuildInstanceDifficulty:SetAlpha(0.9)
    GarrisonLandingPageMinimapButton:SetAlpha(0.9)
end
Minimap:SetScript("OnEnter", Show)

-- onleave/hide
local lasttime = 0
local function Hide()
    if Minimap:IsMouseOver() then return end
    if time() == lasttime then return end
    GameTimeFrame:SetAlpha(0)
    TimeManagerClockButton:SetAlpha(0)
    MiniMapTracking:SetAlpha(0)
    MiniMapChallengeMode:SetAlpha(0)
    MiniMapInstanceDifficulty:SetAlpha(0)
    GuildInstanceDifficulty:SetAlpha(0)
    GarrisonLandingPageMinimapButton:SetAlpha(0)
end
local function SetTimer()
    lasttime = time()
    C_Timer.After(1.5, Hide)
end
Minimap:SetScript("OnLeave", SetTimer)
aLib:RegisterCallback("PLAYER_ENTERING_WORLD", Hide)
Hide(Minimap)

local function beautify()

local object = CreateFrame("Frame")
    Minimap:CreateBeautyBorder(10)
end
aLib:RegisterCallback("PLAYER_ENTERING_WORLD", beautify)
