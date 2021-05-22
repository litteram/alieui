local A, ns = ...

local function initMapPinsTrack()
    local function onUserWaypointUpdated()
        if C_Map.HasUserWaypoint() == true then
            C_Timer.After(0, function()
                              C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end);
        end
    end
    ns.L:RegisterCallback("USER_WAYPOINT_UPDATED", onUserWaypointUpdated)
end
ns.L:RegisterModule("MapPinsTrack", initMapPinsTrack)

local function initMapPinsAlpha()
    if not ns.L.db.global.MapPinsAlpha then return end
    local dAlpha = SuperTrackedFrame.GetTargetAlphaBaseValue;
    function SuperTrackedFrame:GetTargetAlphaBaseValue()
        if dAlpha(self) == 0 and C_Navigation.GetDistance() >= 999 then
            return 0.6;
        else
            return dAlpha(self)
        end
    end
end
ns.L:RegisterModule("MapPinsAlpha", initMapPinsAlpha)

local function findZone(z,s)
    for i=0,2000 do
        if C_Map.GetMapInfo(i) then
            local m = C_Map.GetMapInfo(i)
            if string.lower(m.name) == z then
                if s ~= 0 then
                    if m.parentMapID == s then
                        return i
                    end
                else
                    return i;
                end
            end
        end
    end
    return 0
end

local wrongseparator = "(%d)" .. (tonumber("1.1") and "," or ".") .. "(%d)"
local rightseparator =   "%1" .. (tonumber("1.1") and "." or ",") .. "%2"

local function slashMapPinCmd(msg)
    msg = msg and string.lower(msg)
    msg = msg:gsub("(%d)[%.,] (%d)", "%1 %2"):gsub(wrongseparator, rightseparator)

    local mapId, x, y = string.match(msg,
            "\#?([%d]*)%s*([%d]+[\.\,][%d]+)%s+([%d]+[\.\,][%d]+)")
    output(zone, x, y)

    local playerMap = C_Map.GetBestMapForUnit("player") 
    local playerPos = C_Map.GetPlayerMapPosition(playerMap, "player")

    -- local point = UiMapPoint.CreateFromCoordinates(playerMap, tonumber(x)/100, tonumber(y)/100);

    if C_Map.CanSetUserWaypointOnMap(mapId) then
        -- local pos = C_Map.GetPlayerMapPosition(mapID, "player")
        local mapPoint = UiMapPoint.CreateFromVector2D(mapID, {x=x, y=y})
        C_Map.SetUserWaypoint(mapPoint)

        C_SuperTrack.SetSuperTrackedUserWaypoint(true);
    else
        print("Cannot set waypoints on this map")
    end
end


SLASH_UMPD1 = "/uway";
SLASH_UMPD2 = "/pin";
SlashCmdList["UMPD"] = slashMapPinCmd

-- TomTom-like function
local function initTomTom()
    if not aLieDB.MapPinsTomTom then return end

    -- TomTom global
    TomTom = {}
    -- TomTom:AddWaypoint(mapId, x, y, {title, persistent, minimap, world})
    function TomTom:AddWaypoint(mapId, x, y, _)
        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(zone, x, y))
        C_SuperTrack.SetSuperTrackedUserWaypoint(true);
    end

    SLASH_UMPD3 = "/way";
end
ns.L:RegisterModule("MapPinsTomTom", initTomTom)
