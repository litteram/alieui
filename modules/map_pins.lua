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
    if not aLieDB.MapPinsAlpha then return end
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

local function slashMapPinCmd(msg)
    local zoneFound = 0
    msg = msg and string.lower(msg)

    local wrongseparator = "(%d)" .. (tonumber("1.1") and "," or ".") .. "(%d)"
    local rightseparator =   "%1" .. (tonumber("1.1") and "." or ",") .. "%2"

    local tokens = {}
    msg = msg:gsub("(%d)[%.,] (%d)", "%1 %2"):gsub(wrongseparator, rightseparator)
    for token in msg:gmatch("%S+") do
        table.insert(tokens, token)
    end

    for i = 1, #tokens do
        local token = tokens[i]
        if tonumber(token) then
            zoneFound = i - 1
            break
        end
    end

    local c = {}
    local p="player" 
    local u=C_Map.GetBestMapForUnit(p) 
    local m=C_Map.GetPlayerMapPosition(u,p)

    c.z, c.x, c.y = table.concat(tokens, " ", 1, zoneFound), select(zoneFound + 1, unpack(tokens))

    if c.x and c.y then
        if c.z and string.len(c.z) > 1 then
            c.s = string.match(c.z, ":([a-z%s'`]+)");
            c.z = string.match(c.z, "([a-z%s'`]+)");
            c.z = string.gsub(c.z, '[ \t]+%f[\r\n%z]', '')

            local sub = 0
            if c.s and string.len(c.s) > 0 then
                c.s = string.gsub(c.s, '[ \t]+%f[\r\n%z]', '')
                sub = findZone(c.s,0)
            end
            local zone = findZone(c.z,sub)
            if zone ~= 0 then
                u = zone
            end
        end

        C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(u,tonumber(c.x)/100,tonumber(c.y)/100));
        C_SuperTrack.SetSuperTrackedUserWaypoint(true);
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
