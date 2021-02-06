local A, ns = ...
ns.L = LibStub("AceAddon-3.0"):NewAddon("aLie", "AceEvent-3.0", "AceConsole-3.0")
local L = ns.L

function L.optget(info, value)
    return L.db.global[info[#info]]
end

function L.optset(info, value)
    L.db.global[info[#info]] = value
    L:debug("The " .. info[#info] .. " was set to: " .. tostring(value) )
end

function L.copyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[L.copyTable(orig_key)] = L.copyTable(orig_value)
        end
        setmetatable(copy, L.copyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local defaults = {
    global = {
        cvars = false,
        autoUiScale = true,
        fastLoot = true,
        vignetteAlerts = true,
        screenSaver = true,
        screenshotAchi = true,
        combatTextTweaks = true,
        altbuy = true,
        sellPoors = true,
        repair = true,
        repairGuild = false,
        MapPinsTrack = true,
        MapPisAlpha = true,
        MapPinsTomTom = true,
        errorsFilter = true,
        moveDefaultUF = true,

        -- more settings
        moveDefaultUFSettings = {
            player = {-160, -300},
            target = {160, -300},
            focus  = {400, -300},
        }
    },
}

local options = {
    type = "group",
    inline = true,
    args = {
        _ = {
            name = 'A simple set of lightweight tweaks',
            type = 'description',
            order = 0,
        },
        advGameTweaks = {
            type = "group",
            name = "Advanced tweaks",
            inline = true,
            args = {
                _ = {
                    name = 'Warning, this options will require a manual /reload \n',
                    type = 'description',
                    order = 0,
                },
                cvars = {
                    name = "cVars",
                    desc = "Enable the cVars module",
                    type = "toggle",
                },
                autoUiScale = {
                    name = "AutomaticUIScale",
                    desc = "Automatically select a pixel-perfect UI Scale",
                    type = "toggle",
                },
                errorsFilter = {
                    name = "Errors Filter",
                    desc = "Filter useless UI errors (eg. Ability is not ready)",
                    type = "toggle",
                },
                moveDefaultUF = {
                    name = "Move Unit Frames",
                    desc = "Move default Unit Frames in the center of the screen",
                    type = "toggle",
                },
            },
        },
        gameTweaks = {
            type = "group",
            inline = true,
            name = "Game Tweaks",
            args = {
                fastLoot = {
                    name = "Fast Autoloot",
                    desc = "Incredibly fast autoloot",
                    type = "toggle",
                },
                vignetteAlerts = {
                    name = "Vignette Alerts",
                    desc = "Alerts when you detect a rare npc, chest or item",
                    type = "toggle",
                },
                screenSaver = {
                    name = "Screensaver",
                    desc = "Use an AFK screensaver, it's cool",
                    type = "toggle",
                },
                screenshotAchi = {
                    name = "Screenshot Achivements",
                    desc = "Automatically Screenshot achievements moments",
                    type = "toggle",
                },
                combatTextTweaks = {
                    name = "CombatTextTweaks",
                    desc = "Combat Text tweaks",
                    type = "toggle",
                },
            }
        },
        merchant = {
            name = "Merchant Tweaks",
            type = "group",
            inline = true,
            args = {
                altbuy = {
                    name = "AltBuy",
                    desc = "Buy a full stack with Alt",
                    type = "toggle",
                },
                sellPoors = {
                    name = "SellPoor",
                    desc = "Sell gray items while visiting a vendor",
                    type = "toggle",
                },
                repair = {
                    name = "AutoRepair",
                    desc = "Automatically repair gear when visiting an able smith.",
                    type = "toggle",
                },
                repairGuild = {
                    name = "Auto RepairGuild",
                    desc = "Automatically repair gear using guild funds when visiting an able smith.",
                    type = "toggle",
                },
            },
        },
        mapPinsThings = {
            name = "MapPins",
            type = "group",
            inline = true,
            args = {
                MapPinsTrack = {
                    name = "Track",
                    desc = "Automatically track Map Pins when created",
                    type = "toggle",
                },
                MapPinsAlpha = {
                    name = "Always Show",
                    desc = "Always show MapPins even when very far away",
                    type = "toggle"
                },
                MapPinsTomTom = {
                    name = "TomTom Integration",
                    desc = "TomTom integration, use MapPins when TomTom is not loaded",
                    type = "toggle"
                },
            },
        },
        reloadBtn = {
            type = "execute",
            name = "Reload UI",
            order = -1,
            func = function() ReloadUI() end
        },
    },
    get = L.optget,
    set = L.optset,
}

function L:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("aLieDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable(A, options, {"alie"})
    self.options = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(A, "aLie Tweaks");

    for n,f in pairs(self.modules) do
        if self.db.global[n] and self.modules[n] then
            self.debug("enabling " .. n)
            self.modules[n]()
        end
    end
end

function L:OnEnable()
end

function L:OnDisable()
end

function L.debug(...)
    if not L.db.profile.debug then return nil end
    print(...)
end

SLASH_ALIE_DBG1 = "/aliedebug"
SlashCmdList["ALIE_DBG"] = function()
    L.db.profile.debug = not L.db.profile.debug
    L.debug("enabled")
end

function L:RegisterCallback(event, callback, ...)
    if callback == nil then aLie:l("callback for "..event.." is nil!") end
    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
        function self.eventFrame:OnEvent(event, ...)
            for callback, args in next, self.callbacks[event] do
                callback(args, event, ...)
            end
        end
        self.eventFrame:SetScript("OnEvent", self.eventFrame.OnEvent)
    end
    if not self.eventFrame.callbacks then self.eventFrame.callbacks = {} end
    if not self.eventFrame.callbacks[event] then self.eventFrame.callbacks[event] = {} end

    self.eventFrame.callbacks[event][callback] = {...}
    self.eventFrame:RegisterEvent(event)
end

function L:RegisterModule(name, initfn)
    self.modules[name] = initfn
end

function L:CallElementFunction(element, func, ...)
    if element and func and element[func] then
        element[func](element, ...)
    end
end

SLASH_ALIE_RL1 = "/rl";
SlashCmdList["ALIE_RL"] = function() ReloadUI() end
