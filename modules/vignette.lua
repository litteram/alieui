local A, ns = ...

-- Forked from rVignette by zork - 2014

local function onVignetteAlert(self, evt, id)
    if not aLieDB.VignetteAlerts then return end
    if not id then return end

    self.vignettes = self.vignettes or {}
    if self.vignettes[id] then return end

    local vignetteInfo = C_VignetteInfo.GetVignetteInfo(id)
    if not vignetteInfo then return end

    local atlasInfo = C_Texture.GetAtlasInfo(vignetteInfo.atlasName)
    local left = atlasInfo.leftTexCoord * 256
    local right = atlasInfo.rightTexCoord * 256
    local top = atlasInfo.topTexCoord * 256
    local bottom = atlasInfo.bottomTexCoord * 256

    local str = "|TInterface\\MINIMAP\\ObjectIconsAtlas:0:0:0:0:256:256:"..(left)..":"..(right)..":"..(top)..":"..(bottom).."|t"

    if vignetteInfo.name ~= "Garrison Cache" and vignetteInfo.name ~= "Full Garrison Cache" and vignetteInfo.name ~= nil then
        RaidNotice_AddMessage(RaidWarningFrame, str.." "..vignetteInfo.name.." spotted!", ChatTypeInfo["RAID_WARNING"])
        print(str.." "..vignetteInfo.name,"spotted!")
        self.vignettes[id] = true
    end
end

ns.L:RegisterModule(
    "VignetteAlert",
    function()
        ns.L:RegisterCallback("VIGNETTE_MINIMAP_UPDATED", onVignetteAlert)
    end
)
