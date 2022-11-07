local A, ns = ...
local L = ns.L

ns.L:RegisterCallback("USER_WAYPOINT_UPDATED", function()
    if C_Map.HasUserWaypoint() == true then
        C_Timer.After(
            0,
            function()
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end);
    end
end)

L:RegisterCallback('PLAYER_ENTERING_WORLD', function()
    local dAlpha = SuperTrackedFrame.GetTargetAlphaBaseValue;
    function SuperTrackedFrame:GetTargetAlphaBaseValue()
        if dAlpha(self) == 0 and C_Navigation.GetDistance() >= 999 then
            return 0.6;
        else
            return dAlpha(self)
        end
    end
end)

SLASH_UMPD1 = "/uway";
SLASH_UMPD2 = "/pin";
SlashCmdList["UMPD"] = function(msg)
    msg = string.lower(msg):gsub("(%d)[%.,] (%d)", "%1 %2"):gsub("(%d),(%d)", "%1.%1")

    local mapID, x, y = string.match(msg,
                                     [[#?(%d*)%s*(%d+[.,]?%d+)%s+(%d+[.,]?%d+)]])
    local playerMap = C_Map.GetBestMapForUnit("player")
    if mapID == "" or not mapID then
        mapID = playerMap
    else
        mapID = tonumber(mapID)
    end

    x = tonumber(x)
    y = tonumber(y)

    DEFAULT_CHAT_FRAME:AddMessage("\124cffffff00\124Hworldmap:" .. mapID .. ":" .. x * 100 ..":" .. y * 100 ..
                                  "\124h[\124A:Waypoint-MapPin-ChatIcon:13:13:0:0\124aMap Pin: ".. x .." ".. y .."]\124h\124r");

    -- local point = UiMapPoint.CreateFromCoordinates(playerMap, tonumber(x)/100, tonumber(y)/100);
    if C_Map.CanSetUserWaypointOnMap(mapID) then
        C_Map.ClearUserWaypoint();

        local point = UiMapPoint.CreateFromCoordinates(mapID, x/100, y/100)
        C_Map.SetUserWaypoint(point)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true);
    else
        print("Cannot set waypoints on this map")
    end
end

-- TomTom-like function
local function initTomTom()
    if TomTom ~= nil then return end
    --[[
    TomTom = {}
    TomTom:AddWaypoint(mapId, x, y, {title, persistent, minimap, world})
    function TomTom:AddWaypoint(mapId, x, y, z)
        x = tonumber(x)
        y = tonumber(y)
        z = tonumber(z)

        local point = UiMapPoint.CreateFromCoordinates(mapId, x, y, z)
        if C_Map.CanSetUserWaypointOnMap(mapId) then
            C_Map.SetUserWaypoint(point)
            C_SuperTrack.SetSuperTrackedUserWaypoint(true);
        else
            return false
        end
    end
    --]]

    SLASH_UMPD3 = "/way";
end
L:RegisterCallback('PLAYER_ENTERING_WORLD', initTomTom)
