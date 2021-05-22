local A, ns = ...

local function setup()
    local Resolution = select(1, GetPhysicalScreenSize()).."x"..select(2, GetPhysicalScreenSize())
    local PixelPerfectScale = 768 / string.match(Resolution, "%d+x(%d+)")
    local MinimumScale = 0.64
    local uiscale = PixelPerfectScale >= MinimumScale and PixelPerfectScale or 0.64

    SetCVar("uiScale", uiscale)
    SetCVar("useUiScale", 1)
end
ns.L:RegisterModule("autoUIScale", setup)
