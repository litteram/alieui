local A, ns = ...
local L = ns.L

local function setup()
    --editbox font
    ChatFontNormal:SetFont(
        STANDARD_TEXT_FONT, 13, "THINOUTLINE")
    ChatFontNormal:SetShadowOffset(
        {1,-2})
    ChatFontNormal:SetShadowColor(
        0,0,0,0.25)

    --font size
    CHAT_FONT_HEIGHTS = {10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

    --tabs
    CHAT_TAB_HIDE_DELAY = 1
    CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
    CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
    CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1

    --channels
    CHAT_WHISPER_GET              = "From %s "
    CHAT_WHISPER_INFORM_GET       = "To %s "
    CHAT_BN_WHISPER_GET           = "From %s "
    CHAT_BN_WHISPER_INFORM_GET    = "To %s "
    CHAT_YELL_GET                 = "%s "
    CHAT_SAY_GET                  = "%s "
    CHAT_BATTLEGROUND_GET         = "|Hchannel:Battleground|hBG.|h %s: "
    CHAT_BATTLEGROUND_LEADER_GET  = "|Hchannel:Battleground|hBGL.|h %s: "
    CHAT_GUILD_GET                = "|Hchannel:Guild|hG.|h %s: "
    CHAT_OFFICER_GET              = "|Hchannel:Officer|hGO.|h %s: "
    CHAT_PARTY_GET                = "|Hchannel:Party|hP.|h %s: "
    CHAT_PARTY_LEADER_GET         = "|Hchannel:Party|hPL.|h %s: "
    CHAT_PARTY_GUIDE_GET          = "|Hchannel:Party|hPG.|h %s: "
    CHAT_RAID_GET                 = "|Hchannel:Raid|hR.|h %s: "
    CHAT_RAID_LEADER_GET          = "|Hchannel:Raid|hRL.|h %s: "
    CHAT_RAID_WARNING_GET         = "|Hchannel:RaidWarning|hRW.|h %s: "
    CHAT_INSTANCE_CHAT_GET        = "|Hchannel:Battleground|hI.|h %s: "
    CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:Battleground|hIL.|h %s: "
    --CHAT_MONSTER_PARTY_GET       = CHAT_PARTY_GET
    --CHAT_MONSTER_SAY_GET         = CHAT_SAY_GET
    --CHAT_MONSTER_WHISPER_GET     = CHAT_WHISPER_GET
    --CHAT_MONSTER_YELL_GET        = CHAT_YELL_GET
    CHAT_FLAG_AFK = "<AFK> "
    CHAT_FLAG_DND = "<DND> "
    CHAT_FLAG_GM = "<[GM]> "

    --remove the annoying guild loot messages by replacing them with the original ones
    YOU_LOOT_MONEY_GUILD = YOU_LOOT_MONEY
    LOOT_MONEY_SPLIT_GUILD = LOOT_MONEY_SPLIT

    --don't cut the toastframe
    BNToastFrame:SetClampedToScreen(true)
    BNToastFrame:SetClampRectInsets(-15,15,15,-15)

    --ChatFrameMenuButton
    ChatFrameMenuButton:HookScript("OnShow", ChatFrameMenuButton.Hide)
    ChatFrameMenuButton:Hide()
    --ChatFrameChannelButton
    ChatFrameChannelButton:HookScript("OnShow", ChatFrameChannelButton.Hide)
    ChatFrameChannelButton:Hide()
    --ChatFrameToggleVoiceDeafenButton
    ChatFrameToggleVoiceDeafenButton:HookScript("OnShow", ChatFrameToggleVoiceDeafenButton.Hide)
    ChatFrameToggleVoiceDeafenButton:Hide()
    --ChatFrameToggleVoiceMuteButton
    ChatFrameToggleVoiceMuteButton:HookScript("OnShow", ChatFrameToggleVoiceMuteButton.Hide)
    ChatFrameToggleVoiceMuteButton:Hide()

    --hide the friend micro button
    local button = QuickJoinToastButton or FriendsMicroButton
    button:HookScript("OnShow", button.Hide)
    button:Hide()

    --skin chat
    for i = 1, NUM_CHAT_WINDOWS do
        local chatframe = _G["ChatFrame"..i]
        SkinChat(chatframe)
        --adjust channel display
        if (i ~= 2) then
            chatframe.DefaultAddMessage = chatframe.AddMessage
            chatframe.AddMessage = AddMessage
        end
    end

end

L:RegisterModule("chat", setup)
