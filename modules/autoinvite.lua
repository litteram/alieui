local _, ns = ...

local function AutoInvite_IsInGuild(player)
	local numTotal = GetNumGuildMembers(true);
	for i=1,numTotal do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		if (string.upper(name) == string.upper(player)) then
			return true;
		end
	end
	return nil;
end

local function AutoInvite_Event(self, event, ...)
	local args = { select(1, ...) }
	if (event == 'CHAT_MSG_WHISPER') then
		if (GetNumRaidMembers() > 0) then -- in a raid
			if (IsRaidOfficer()) or (IsRaidLeader()) then -- can invite
				if strfind(args[1],"^invite") or (args[1] == "inv") or strfind(args[1],"^inv pl") then
					-- make sure this player is in the guild
					if (AutoInvite_IsInGuild(args[2])) then
						if GetNumRaidMembers() ~= 40 then
							InviteUnit(args[2])
						else
							SendChatMessage("Autoreply: The raid is currently full", "WHISPER", nil, name)
						end
					end
				else
					return
				end
			end
		end
	end
end

local function AutoInvite_Msg(msg)
	if (msg) then
		if (string.len(msg) > 0) then
			if(DEFAULT_CHAT_FRAME) then
				DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. msg);
			end
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffffffff" .. 'No Message');
		end
	end
end

local function onWhisper(event, ...)
    local args = {select(1, ...)}
    if 
end

local function setup()
    ns.L:RegisterCallback("CHAT_MSG_WHISPER", onWhisper)
end

ns:RegisterModule("AutoInvite", setup)

--[[
--
--	WhisperInvite
--	by Dust of Turalyon
--
--	Naming Convention:
--	- Methods are first letter upper case, camel case
--	- Member variables are first letter lower case
--	- Static handlers start with "On".
--
--]]

local addonName, WhisperInvite = ...;

WhisperInvite.name = addonName;
WhisperInvite.version = GetAddOnMetadata(addonName, "Version");

function WhisperInvite:Invite(name)
	if not self.settings.enabled then
		return false, "disabled";
	end
	if not IsInRaid() then
		-- Not in raid
		if not IsInGroup() then
			-- Solo
			InviteUnit(name);
			return true;
		else
			-- Party
			if not UnitIsGroupLeader("player") then
				return false, "permission";
			end
			if GetNumGroupMembers() == 4 then
				if self.settings.autoconvert then
					ConvertToRaid();
				else
					return false, "party full";
				end;
			end
			InviteUnit(name);
			return true;
		end
	else
		-- Raid
		if GetNumGroupMembers() < 40 then
			if not UnitIsRaidOfficer("player") and not UnitIsGroupLeader("player") then
				return false, "permission";
			end;
			InviteUnit(name);
			return true;
		else
			return false, "raid full";
		end;
	end;
end;

--[[ Event Management ]]
function WhisperInvite:RegisterEvents(eventList)
	for event, handler in pairs(eventList) do
		self.eventFrame:RegisterEvent(event);
	end
end;

function WhisperInvite:UnregisterEvents(eventList)
	for event, handler in pairs(eventList) do
		self.eventFrame:UnregisterEvent(event);
	end
end;

--[[ Frame Event Handling ]]
WhisperInvite.events = {
	["VARIABLES_LOADED"] =
		function (self)
			if not WhisperInvite_Persistent then
				WhisperInvite_Persistent =
				{
					enabled = true;
					autoconvert = true;
					keyword = "invite";
				};
			end;
			self.settings = WhisperInvite_Persistent;
		end;
	["PLAYER_REGEN_DISABLED"] = nil;
	["PLAYER_REGEN_ENABLED"] = nil;
	["CHAT_MSG_WHISPER"] =
		function (self, message, sender)
			if string.lower(message) == self.settings.keyword then
				local success, reason = self:Invite(sender);
				if not success then
					SendChatMessage("Invite Error: "..reason, "WHISPER", nil, sender);
				end;
			end
		end;
	["CHAT_MSG_SYSTEM"] =
		function (self, message, sender)
			local sender = string.match(message, self.errAlreadyInGroup);
			if sender then
				SendChatMessage("Invite Error: ".."already in group", "WHISPER", nil, sender);
			end
		end;
}

WhisperInvite.OnEvent = function (frame, event, ...)
	local self = WhisperInvite; -- Static Method
	if self.events[event] then
		self.events[event](self, ...);
	else
		self:Message("WhisperInvite Error: Unknown Event");
	end;
end;

--[[ Slash Commands]]
WhisperInvite.slashCommands = {
	["enable"] =
		function (self)
			self.settings.enabled = true;
			self:Message("WhisperInvite enabled");
		end;
	["disable"] =
		function (self)
			self.settings.enabled = false;
			self:Message("WhisperInvite disabled");
		end;
	["keyword"] =
		function (self, keyword)
			self.settings.keyword = keyword;
			self:Message("WhisperInvite keyword set to "..self.settings.keyword);
		end;
	["autoraid"] =
		function (self, command)
			if command == "enable" then
				self.settings.autoconvert = true;
			elseif command == "disable" then
				self.settings.autoconvert = false;
			else
				self.settings.autoconvert = not self.settings.autoconvert;
			end
			self:Message("WhisperInvite auto raid conversion "..
				(self.settings.autoconvert and "enabled" or "disabled"));
		end;
	["promote"] =
		function (self)
			self:Message("WhisperInvite promoting everyone");
			local raidMemberCount = GetRealNumRaidMembers();
			for i = 1,raidMemberCount do
				PromoteToAssistant("raid"..i);
			end
		end;
};

WhisperInvite.OnSlashCommand = function (msg)
	local self = WhisperInvite; -- Static Method
	local cmd, arg = string.match(string.lower(msg), "^(%a*)%s*(.*)$");
	if cmd then
		if self.slashCommands[cmd] then
			self.slashCommands[cmd](self, arg);
		else
			self:Message("WhisperInvite:")
			self:Message("/whisperinvite enable|disable");
			self:Message("/whisperinvite keyword <keyword>");
			self:Message("/whisperinvite autoraid [enable|disable]");
			self:Message("/whisperinvite promote");
		end;
	end;
end;

-- [[ Misc ]]
function WhisperInvite:Message(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end;

-- [[ Load Event Handling ]]
function WhisperInvite:Load()
	-- Slash command
	SlashCmdList["WHISPERINVITE"] = self.OnSlashCommand;
	SLASH_WHISPERINVITE1 = "/whisperinvite";
	-- Events
	self.eventFrame = CreateFrame("Frame", nil, UIParent);
	self.eventFrame:SetScript("OnEvent", self.OnEvent);
	self:RegisterEvents(self.events);
end;


WhisperInvite.errAlreadyInGroup = string.gsub(ERR_ALREADY_IN_GROUP_S, "%%s", "(%%a*)");

WhisperInvite:Load();
