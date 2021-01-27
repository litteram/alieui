local _,ns= ...

SlashCmdList["AFF"] = function(msg)
    SetCVar("Sound_EnableSFX", 0)
    UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
end
SLASH_AFF1 = "/aff"

SlashCmdList["ASS"] = function(msg)
    UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
    SetCVar("Sound_EnableSFX", 1)
end
SLASH_ASS1 = "/ass"
