local kLocalVoiceFontColor         = Color(0.50, 1.00, 0.50, 1)
local kLocalVoiceTeamOnlyFontColor = Color(0.75, 0.10, 0.75, 1)

local ClearAllBars
local GetFreeBar
local kBackgroundOffset
local kBackgroundYSpace
local kBackgroundSize
local kBackgroundTexture
local kVoiceChatIconOffset

local voice_teamonly = table.array(100)

Client.HookNetworkMessage("LocalTalkExtended_teamonly_notify", function(msg)
	voice_teamonly[msg.client] = msg.on
end)

local team_only
debug.replacemethod("GUIVoiceChat", "SendKeyEvent",
function(self, key, down, amount)
	local player = Client.GetLocalPlayer()

	if down then
		if ChatUI_EnteringChatMessage() then return end

		local bind = player:isa "Commander" and "VoiceChatCom" or "VoiceChat"
		if GetIsBinding(key, bind) then
			self.recordBind    = bind
			self.recordEndTime = nil

			Client.VoiceRecordStartGlobal()
		elseif GetIsBinding(key, "LocalVoiceChat") then
			self.recordBind    = "LocalVoiceChat"
			self.recordEndTime = nil

			if team_only ~= false then
				team_only = false
				Client.SendNetworkMessage("LocalTalkExtended_teamonly", {on = false}, true)
			end
			Client.VoiceRecordStartEntity(player, Vector.origin)
		elseif GetIsBinding(key, "LocalVoiceChatTeam") then
			self.recordBind    = "LocalVoiceChatTeam"
			self.recordEndTime = nil

			if team_only ~= true then
				team_only = true
				Client.SendNetworkMessage("LocalTalkExtended_teamonly", {on = true}, true)
			end
			Client.VoiceRecordStartEntity(player, Vector.origin)
		end
	elseif self.recordBind and GetIsBinding(key, self.recordBind) then
		self.recordBind = nil
		self.recordEndTime = Shared.GetTime() + Client.GetOptionFloat("recordingReleaseDelay", 0.15)
	end
end)

debug.replacemethod("GUIVoiceChat", "Update",
function(self, delta_time)
	PROFILE("GUIVoiceChat:Update")

	if self.recordEndTime and self.recordEndTime < Shared.GetTime() then
		Client.VoiceRecordStop()
		self.recordEndTime = nil
	end

	ClearAllBars(self)

	local players = ScoreboardUI_GetAllScores()
	local local_team = Client.GetLocalPlayer():GetTeamNumber()
	local local_client = Client.GetLocalClientIndex()
	local bar_position = Vector(kBackgroundOffset)

	for i = 1, #players do
		local player = players[i]

		local client = player.ClientIndex
		local channel = client and ChatUI_GetVoiceChannelForClient(client) or VoiceChannel.Invalid

		if channel ~= VoiceChannel.Invalid then
			local bar = GetFreeBar(self)

			local team = player.EntityTeamNumber

			local color =
				channel ~= VoiceChannel.Global and (
					team == local_team and (
						client == local_client and team_only or voice_teamonly[client]
					) and kLocalVoiceTeamOnlyFontColor or
					kLocalVoiceFontColor
				) or
				player.IsCommander and GUIVoiceChat.kCommanderFontColor or
				team == 1 and GUIVoiceChat.kMarineFontColor or
				team == 2 and GUIVoiceChat.kAlienFontColor or
				GUIVoiceChat.kSpectatorFontColor

			bar.Name:SetText(player.Name)
			bar.Name:SetColor(color)

			bar.Icon:SetColor(color)

			bar.Background:SetTexture(string.format(kBackgroundTexture, team == 2 and "alien" or "marine"))
			bar.Background:SetColor(team ~= 1 and team ~= 2 and Color(1, 200/255, 150/255, 1) or Color(1, 1, 1, 1))
			bar.Background:SetLayer(kGUILayerDeathScreen+1)
			bar.Background:SetIsVisible(self.visible)
			bar.Background:SetPosition(bar_position)

			bar_position.y = bar_position.y + kBackgroundSize.y + kBackgroundYSpace
		end
	end
end)
