local A, aLie = ...

aLie.addonName = A
aLie.color = "00FFFFFF"
aLie.commands = {}
aLie.commands_help = {}
aLie.modules = {}
-- Initialization
function aLie_OnLoad(self)
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ADDON_LOADED")
end

function aLie_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        SetCVar("ScreenshotQuality", 10)
    elseif event == "ADDON_LOADED" then
        -- first load
        if aLieDB == nil then
            aLieDB = aLieDBDefaults
        end

        local name = ...
        if name == A then
            for mod,enabled in pairs(aLieDB) do
                if aLie.modules[mod] then
                    aLie.modules[mod]()
                end
            end
        end
    end
end

function aLie:CopyTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[aLie:CopyTable(orig_key)] = aLie:CopyTable(orig_value)
        end
        setmetatable(copy, aLie:CopyTable(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function aLie:RegisterCallback(event, callback, ...)
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

function aLie:RegisterModule(name, initfn)
    self.modules[name] = initfn
end

function aLie:CallElementFunction(element, func, ...)
    if element and func and element[func] then
        element[func](element, ...)
    end
end


function aLie:l(msg, color)
    print("|c"..(color or aLie.color).."|r "..msg)
end

function aLie:CreateSlashCmd(shortcut, fn, help)
    if not addonName or not shortcut or not frames then return end
    SlashCmdList[shortcut] = fn
    _G["SLASH_"..shortcut.."1"] = "/"..shortcut
    aLie:l(addonName, "|c"..(color or aLie.color).."/"..shortcut.."|r "..(help or "command registered"))
end

function aLie:addSlashCommand(shortcut, fn, help)
    aLie.commands[shortcut] = fn
    aLie.commands_help[shortcut] = (_G["SLASH_ALIE1"] .. " " .. shortcut .. " [options] " .. (help or ""))
end

local function OnSlashCommand(msg)
    local cmd = {}
    for i in string.gmatch(string.lower(msg or ""), "%S+") do
        table.insert(cmd, i)
    end

    if #cmd < 1 or cmd[1] == "help" or cmd[1] == "h" or not aLie.commands[cmd[1]] then
        print "Helpy paris"
        for _, i in ipairs(aLie.commands_help) do
            print(i)
        end
        return print("")
    else
        aLie.commands[cmd[1]](cmd)
    end
end

SlashCmdList["ALIE"] = OnSlashCommand
SLASH_ALIE1 = "/alie"

-- ???
SlashCmdList["ACTIONCAM"] = function(msg)
    if msg == "basic" or msg == "full" or msg == "off" then
        ConsoleExec("actioncam "..msg)
    else
        print("ActionCam Options: basic, full, off")
    end
end
SLASH_ACTIONCAM1 = "/actioncam"

aLie:addSlashCommand(
    "reset",
    function()
        aLieDB = aLie:CopyTable(aLieDBDefaults)
        print("aLie database reset to default")
    end,
    "reset options to default")

aLie:addSlashCommand(
    "db",
    function()
        for k,v in pairs(aLieDB) do
            print(A.."."..k..": "..tostring(v))
        end
    end,
    "Show aLie database"
)
